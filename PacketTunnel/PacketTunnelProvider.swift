import NetworkExtension
import leaf

// Leaf runtime ID
let rtId: UInt16 = 0

// Connection status key for App Groups shared storage
let connectionStatusKey = "CONNECTION_STATUS_KEY"

public enum TunnelError: Error {
    case notFound
}

enum ConnectionStatus: String {
    case checking = "checking"
    case ok = "ok"
    case error = "error"
    case none = "none"
}

class PacketTunnelProvider: NEPacketTunnelProvider {
    // Health check timer
    private var healthCheckTimer: DispatchSourceTimer?
    private var isRunning = false
    private var tunnelFileDescriptor: Int32? {
        var buf = [CChar](repeating: 0, count: Int(IFNAMSIZ))
        for fd: Int32 in 0...1024 {
            var len = socklen_t(buf.count)
            if getsockopt(fd, 2, 2, &buf, &len) == 0 && String(cString: buf).hasPrefix("utun") {
                return fd
            }
        }
        return nil
    }
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "240.0.0.1")
        settings.ipv4Settings = NEIPv4Settings(addresses: ["240.0.0.2"], subnetMasks: ["255.255.255.0"])
        settings.ipv4Settings?.includedRoutes = [NEIPv4Route.`default`()]
        settings.dnsSettings = NEDNSSettings(servers: ["1.1.1.1"])
        settings.mtu = 1500
        setTunnelNetworkSettings(settings) { error in
            NSLog("VPN tunnel started.")
            
            // Certificate store for OpenSSL.
            let bundle = Bundle(for: Self.self)
            let bundlePath = bundle.resourcePath!
            setenv("SSL_CERT_DIR", bundlePath, 1)
            setenv("SSL_CERT_FILE", bundle.path(forResource: "cacert", ofType: ".pem"), 1)
            
            // Some settings to free resources more aggressive.
            setenv("TCP_UPLINK_TIMEOUT", "0", 1)
            setenv("TCP_DOWNLINK_TIMEOUT", "0", 1)
            setenv("UDP_SESSION_TIMEOUT", "15", 1)
            setenv("UDP_SESSION_TIMEOUT_CHECK_INTERVAL", "5", 1)
            
            if let config = UserDefaults.init(suiteName: appGroup)?.string(forKey: configKey) {
                let config = config.replacingOccurrences(of: "{{TUN-FD}}", with: String(self.tunnelFileDescriptor!))
                DispatchQueue.global(qos: .userInteractive).async {
                    leaf_run_with_config_string(rtId, config)
                }
                self.isRunning = true
                self.startHealthCheckMonitoring()
                completionHandler(nil)
            } else {
                NSLog("Config not found")
                completionHandler(TunnelError.notFound)
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        self.isRunning = false
        self.stopHealthCheckMonitoring()
        self.updateConnectionStatus(.none)
        leaf_shutdown(rtId)
        NSLog("VPN tunnel stopped.")
        completionHandler()
    }

    // MARK: - Health Check Monitoring

    /// Start periodic health check monitoring
    private func startHealthCheckMonitoring() {
        let outboundTag = "Proxy"
        let checkInterval: TimeInterval = 10 // Check every 10 seconds for faster detection
        let delayStart: TimeInterval = 5 // 5 seconds delay before first check
        let maxActiveSeconds: UInt32 = 15 // Consider idle if no activity for 15 seconds

        // Give some time for VPN startup
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delayStart) { [weak self] in
            guard let self = self, self.isRunning else { return }

            self.healthCheckTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
            self.healthCheckTimer?.schedule(deadline: .now(), repeating: checkInterval)
            self.healthCheckTimer?.setEventHandler { [weak self] in
                guard let self = self, self.isRunning else { return }
                self.performHealthCheck(outboundTag: outboundTag, maxActiveSeconds: maxActiveSeconds)
            }
            self.healthCheckTimer?.resume()

            // Perform initial check
            self.performHealthCheck(outboundTag: outboundTag, maxActiveSeconds: maxActiveSeconds)
        }
    }

    /// Stop health check monitoring
    private func stopHealthCheckMonitoring() {
        healthCheckTimer?.cancel()
        healthCheckTimer = nil
    }

    /// Perform health check and write results to App Groups
    private func performHealthCheck(outboundTag: String, maxActiveSeconds: UInt32) {
        // Update status to checking
        updateConnectionStatus(.checking)

        // Check if there's active connection
        var sinceLastActive: UInt32 = 0
        let sinceResult = leaf_get_since_last_active(rtId, outboundTag, &sinceLastActive)

        var needsHealthCheck = false
        if sinceResult != 0 {
            // Error or no data (ERR_NO_DATA = 9), need health check
            needsHealthCheck = true
        } else if sinceLastActive > maxActiveSeconds {
            // Last active was more than maxActiveSeconds ago, need health check
            needsHealthCheck = true
        }

        if needsHealthCheck {
            // Perform health check with 5 second timeout
            let healthCheckResult = leaf_health_check(rtId, outboundTag, 5000)
            if healthCheckResult != 0 {
                // Health check failed
                updateConnectionStatus(.error)
            } else {
                // Health check passed
                updateConnectionStatus(.ok)
            }
        } else {
            // Connection is active (<= maxActiveSeconds), status is OK
            updateConnectionStatus(.ok)
        }
    }

    /// Update connection status and notify main app via Darwin notifications
    private func updateConnectionStatus(_ status: ConnectionStatus) {
        UserDefaults.init(suiteName: appGroup)?.set(status.rawValue, forKey: connectionStatusKey)
        // Use Darwin notification for cross-process communication
        let notificationName = "ConnectionStatusChanged" as CFString
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(notificationName),
            nil,
            nil,
            true
        )
    }
}

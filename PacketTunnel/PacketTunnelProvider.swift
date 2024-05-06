import NetworkExtension
import leaf


let rtId: UInt16 = 0

public enum TunnelError: Error {
    case notFound
}

class PacketTunnelProvider: NEPacketTunnelProvider {
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
                completionHandler(nil)
            } else {
                NSLog("Config not found")
                completionHandler(TunnelError.notFound)
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        leaf_shutdown(rtId)
        NSLog("VPN tunnel stopped.")
        completionHandler()
    }
}

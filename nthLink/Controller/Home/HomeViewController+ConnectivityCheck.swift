//
//  HomeViewController+ConnectivityCheck.swift
//  nthLink
//
//  Created for VPN connectivity health monitoring
//

import UIKit

// Connection status key (must match PacketTunnel)
private let connectionStatusKey = "CONNECTION_STATUS_KEY"

enum ConnectionStatus: String {
    case checking = "checking"
    case ok = "ok"
    case error = "error"
    case none = "none"
}

extension HomeViewController {

    /// Connectivity health state for UI display
    enum ConnectivityState {
        case healthy           // Connection is working normally
        case checking          // Health check in progress
        case unhealthy         // Health check failed, proxy unreachable
    }

    /// Health check result for history tracking
    private enum HealthCheckResult {
        case passed
        case failed
    }

    /// Health check history - tracks last 5 results
    private static var healthCheckHistory: [HealthCheckResult] = []
    private static let maxHistoryCount = 5

    // MARK: - Connectivity Monitoring

    /// Start monitoring connectivity health when VPN is connected
    func startConnectivityMonitoring() {
        // Stop any existing monitoring
        stopConnectivityMonitoring()

        // Register for Darwin notification from PacketTunnel
        let notificationName = "ConnectionStatusChanged" as CFString
        let observer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            observer,
            { _, observer, _, _, _ in
                guard let observer = observer else { return }
                let viewController = Unmanaged<HomeViewController>.fromOpaque(observer).takeUnretainedValue()
                DispatchQueue.main.async {
                    viewController.checkConnectivityHealth()
                }
            },
            notificationName,
            nil,
            .deliverImmediately
        )

        // Fallback: Also poll every 2 seconds in case notifications are missed
        connectivityTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkConnectivityHealth()
        }

        // Perform initial check
        checkConnectivityHealth()

        // Reset connectivity state
        currentConnectivityState = .healthy
    }

    /// Stop monitoring connectivity health
    func stopConnectivityMonitoring() {
        // Unregister Darwin notification observer
        let notificationName = "ConnectionStatusChanged" as CFString
        let observer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            observer,
            CFNotificationName(notificationName),
            nil
        )

        connectivityTimer?.invalidate()
        connectivityTimer = nil
        currentConnectivityState = .healthy

        // Clear health check history when stopping monitoring
        Self.healthCheckHistory.removeAll()
    }

    /// Check connectivity health by reading from App Groups shared storage
    private func checkConnectivityHealth() {
        // Ensure VPN is connected before checking
        guard vpnStatus == .connected else {
            return
        }

        // Read connection status from App Groups (written by PacketTunnel)
        guard let sharedDefaults = UserDefaults(suiteName: appGroup) else {
            NSLog("Unable to access App Groups UserDefaults")
            return
        }

        // Read status from shared storage
        if let statusString = sharedDefaults.string(forKey: connectionStatusKey),
           let status = ConnectionStatus(rawValue: statusString) {
            handleConnectionStatus(status)
        } else {
            handleConnectionStatus(.none)
        }
    }

    /// Handle connection status updates from PacketTunnel
    private func handleConnectionStatus(_ status: ConnectionStatus) {
        let newState: ConnectivityState

        switch status {
        case .checking:
            newState = .checking
        case .ok:
            newState = .healthy
            // Record successful health check
            recordHealthCheck(result: .passed)
        case .error:
            newState = .unhealthy
            // Record failed health check
            recordHealthCheck(result: .failed)
        case .none:
            newState = .healthy
        }

        // Only update UI if state actually changed
        guard currentConnectivityState != newState else {
            return
        }

        currentConnectivityState = newState
        updateConnectivityUI(state: newState)
    }

    /// Record a health check result and update history
    private func recordHealthCheck(result: HealthCheckResult) {
        // Add new result to history
        Self.healthCheckHistory.append(result)

        // Keep only last 5 results
        if Self.healthCheckHistory.count > Self.maxHistoryCount {
            Self.healthCheckHistory.removeFirst()
        }

        // Update emoji slider based on health check history
        updateEmojiSlider()
    }

    /// Calculate slider value based on health check history
    /// - Returns: Slider step (0-4) based on passed checks
    private func calculateSliderValue() -> Int {
        guard !Self.healthCheckHistory.isEmpty else {
            return 2 // Default to Normal (middle) when no history
        }

        // Count how many health checks passed
        let passedCount = Self.healthCheckHistory.filter { $0 == .passed }.count

        // Map passed count to slider value:
        // 5 passed = Very Good (4)
        // 4 passed = Good (3)
        // 3 passed = Normal (2)
        // 2 passed = Poor (1)
        // 0-1 passed = Very Poor (0)
        switch passedCount {
        case 5:
            return 4 // Very Good
        case 4:
            return 3 // Good
        case 3:
            return 2 // Normal
        case 2:
            return 1 // Poor
        default:
            return 0 // Very Poor (0 or 1 passed)
        }
    }

    /// Update emoji slider with current health status
    private func updateEmojiSlider() {
        let sliderValue = calculateSliderValue()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Update the emoji slider (will be implemented when we add the slider)
            self.updateEmojiSliderValue(sliderValue)
        }
    }

    /// Update emoji slider value based on health check history
    func updateEmojiSliderValue(_ value: Int) {
        // Update slider position (no text labels needed - emojis show the state)
        emojiSlider?.currentStep = value
    }

    /// Update UI based on connectivity state
    private func updateConnectivityUI(state: ConnectivityState) {
        // UI updates for connectivity state
        // Note: Only emoji slider shows health status - no warning banners
        // Slider updates automatically via health check history
    }
}

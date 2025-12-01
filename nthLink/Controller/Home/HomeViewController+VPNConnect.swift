//
//  HomeViewController+VPNConnect.swift
//  nthLink
//
//  Created by Vaneet Modgill on 24/02/24.
//

import UIKit
import NetworkExtension

extension HomeViewController {
    
    func createVPNConfiguration () {
        // Load or create a VPN configuration, this will ask user for VPN permission for the first time.
        loadOrCreateVPNManager(completionHandler: { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                print("Unable to load or create VPN manager: \(String(describing: error))")
                self.isVPNConfigurationReady = false

                // Check if this is a permission denial error
                let nsError = error as NSError
                if nsError.domain == "NEVPNErrorDomain" && nsError.code == 5 {
                    // Permission denied - show helpful message
                    DispatchQueue.main.async {
                        self.showVPNPermissionDeniedAlert()
                    }
                } else {
                    // Other error
                    DispatchQueue.main.async {
                        self.showVPNConfigurationErrorAlert()
                    }
                }
                return
            }

            self.isVPNConfigurationReady = true
            self.updateVpnStatus()
            // Observe VPN connection status changes.
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateVpnStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: vpnManager.connection)
        })
    }
    
    func disconnectVPN() {
        vpnManager.connection.stopVPNTunnel()
    }
    

    func connectVPN() {
        // If VPN configuration is not ready, try to create it again (this will re-prompt)
        if !isVPNConfigurationReady {
            createVPNConfiguration()
            return
        }

        if vpnStatus == .disconnected {
            self.showStatus(status: .connecting)
        }

        vpnManager.isEnabled = true
        vpnManager.saveToPreferences { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                print("Unable to save VPN configuration: \(String(describing: error))")

                // Check if permission was denied
                let nsError = error as NSError
                if nsError.domain == "NEVPNErrorDomain" && nsError.code == 5 {
                    self.isVPNConfigurationReady = false
                    DispatchQueue.main.async {
                        self.showStatus(status: .disconnected)
                        self.showVPNPermissionDeniedAlert()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showStatus(status: .disconnected)
                        self.showVPNConfigurationErrorAlert()
                    }
                }
                return
            }

            vpnManager.loadFromPreferences { [weak self] error in
                guard let self = self else { return }

                if let error = error {
                    print("Unable to load VPN configuration: \(String(describing: error))")
                    DispatchQueue.main.async {
                        self.showStatus(status: .disconnected)
                        self.showVPNConfigurationErrorAlert()
                    }
                    return
                }

                NotificationCenter.default.addObserver(self, selector: #selector(self.updateVpnStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: vpnManager.connection)

                switch vpnManager.connection.status {
                case .disconnected, .invalid:
                    DispatchQueue.main.async {
                        self.showStatus(status: .connecting)
                    }
                    self.getServerConfig()
                default:
                    self.disconnectVPN()
                }
            }
        }
    }
    
    func loadOrCreateVPNManager(completionHandler: @escaping (Error?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences(completionHandler: { managers, error in
            guard let managers = managers, error == nil else {
                completionHandler(error)
                return
            }
            // Take an existing VPN configuration or create a new one if none exist.
            if managers.count > 0 {
                vpnManager = managers[0]
                completionHandler(nil)
            } else {
                let manager = NETunnelProviderManager()
                manager.protocolConfiguration = NETunnelProviderProtocol()
                manager.localizedDescription = VPNConstants.localizedDescription
                manager.protocolConfiguration?.serverAddress = VPNConstants.serverAddress
                manager.saveToPreferences { error in
                    if let error = error {
                        completionHandler(error)
                        return
                    }
                    manager.loadFromPreferences { loadError in
                        vpnManager = manager
                        completionHandler(loadError)
                    }
                }
            }
        })
    }

    // MARK: - VPN Permission Alerts

    /// Show alert when user denies VPN configuration permission
    func showVPNPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: LocalizedStringEnum.vpnPermissionDeniedTitle.localized,
            message: LocalizedStringEnum.vpnPermissionDeniedMessage.localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: LocalizedStringEnum.tryAgain.localized,
            style: .default,
            handler: { [weak self] _ in
                // Try again - this will re-prompt for permission
                self?.createVPNConfiguration()
            }
        ))

        alert.addAction(UIAlertAction(
            title: LocalizedStringEnum.Cancel.localized,
            style: .cancel,
            handler: nil
        ))

        present(alert, animated: true, completion: nil)
    }

    /// Show alert for general VPN configuration errors
    func showVPNConfigurationErrorAlert() {
        let alert = UIAlertController(
            title: LocalizedStringEnum.vpnConfigurationErrorTitle.localized,
            message: LocalizedStringEnum.vpnConfigurationErrorMessage.localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: LocalizedStringEnum.OK.localized,
            style: .default,
            handler: nil
        ))

        present(alert, animated: true, completion: nil)
    }


}


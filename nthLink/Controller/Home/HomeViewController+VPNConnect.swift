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
        loadOrCreateVPNManager(completionHandler: { error in
            guard error == nil else {
                print("Unable to load or create VPN manager: \(String(describing: error))")
                return
            }
            self.updateVpnStatus()
            // Observe VPN connection status changes.
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateVpnStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: vpnManager.connection)
        })
    }
    
    func disconnectVPN() {
        vpnManager.connection.stopVPNTunnel()
    }
    
    
    func connectVPN() {
            vpnManager.isEnabled = true
            vpnManager.saveToPreferences { error in
                guard error == nil else {
                    print("Unable to save VPN configuration: \(String(describing: error))")
                    return
                }
                vpnManager.loadFromPreferences { error in
                    guard error == nil else {
                        print("Unable to load VPN configuration: \(String(describing: error))")
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
            } else {
                let manager = NETunnelProviderManager()
                manager.protocolConfiguration = NETunnelProviderProtocol()
                manager.localizedDescription = VPNConstants.localizedDescription
                manager.protocolConfiguration?.serverAddress = VPNConstants.serverAddress
                manager.saveToPreferences { error in
                    guard error == nil else {
                        completionHandler(error)
                        return
                    }
                    manager.loadFromPreferences { error in
                        vpnManager = manager
                    }
                }
            }
            completionHandler(nil)
        })
    }
    
    
}


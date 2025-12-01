//
//  VPNServiceManager.swift
//  nthLink
//
//  Created by Vaneet Modgill on 13/02/24.
//

import Foundation
import NetworkExtension
import Network

class VPNServiceManager:NSObject {
    
    static let sharedInstance = VPNServiceManager()
    var isReachable = true
    let monitor = NWPathMonitor()
    var isVPNConnectedViaDiagnostics = false


    private override init() {
        super.init()
        self.startMonitoring()

    }
    

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                self?.isReachable = true
            } else {
                self?.isReachable = false
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }

    func removeTunnelPreferences(){
        NETunnelProviderManager.loadAllFromPreferences(completionHandler: { managers, error in
            guard let managers = managers, error == nil else {
                print("No configuration")
                return
            }
            for manager in managers {
                if manager.localizedDescription == VPNConstants.localizedDescription {
                    manager.removeFromPreferences()
                }
            }
        })
    }
    
}

//
//  VPNServiceManager.swift
//  nthLink
//
//  Created by Vaneet Modgill on 13/02/24.
//

import Foundation
import NetworkExtension

class VPNServiceManager:NSObject {
    
    static let sharedInstance = VPNServiceManager()

    private override init() {
        super.init()
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

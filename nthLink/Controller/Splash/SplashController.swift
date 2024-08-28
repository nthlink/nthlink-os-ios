//
//  SplashController.swift
//  nthLink
//
//  Created by Vaneet Modgillon 6/29/23.
//

import UIKit
import NetworkExtension

@available(iOS 15.0, *)
class SplashController: AppBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    private func setupInitialData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if UserDefaults.standard.value(forKey: UserDefaultKeys.isPrivacyPolicyAccepted) != nil {
                let homeController = UIStoryboard.loadHomeViewController()
                let menuController = UIStoryboard.loadMenuController()
                let newViewController = RootView(rootViewController: homeController, leftViewController: menuController, rightViewController: nil)
                self.navigationController?.pushViewController(newViewController, animated: true)
                return
            }
            VPNServiceManager.sharedInstance.removeTunnelPreferences()
            let loadPrivacyController = UIStoryboard.loadPrivacyController()
            self.navigationController?.pushViewController(loadPrivacyController, animated: true)
        }
    }

}

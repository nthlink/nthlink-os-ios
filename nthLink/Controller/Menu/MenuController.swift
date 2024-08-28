//
//  MenuController.swift
//  nthLink
//
//  Created by Vaneet Modgillon 6/29/23.
//

import UIKit

@available(iOS 15, *)
class MenuController: AppBaseViewController {
  
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func goHelp(_ sender: Any) {
        UIApplication.shared.open(URL(string: AppConfigurations.getHelpURL())!)
    }
    
    @IBAction func goRate(_ sender: Any) {
        UIApplication.shared.open(URL(string: AppConfigurations.getAppStoreURL())!)
    }
    
    @IBAction func privacyPolicyButtonClicked(_ sender: Any) {
        UIApplication.shared.open(URL(string: AppConfigurations.getPrivacyPolicyURL())!)
    }
    
    
    @IBAction func goFeedback(_ sender: Any) {
        self.navigationDrawerController?.closeLeftView()
        let loadFeedbackController = UIStoryboard.loadFeedbackController()
        self.navigationController?.pushViewController(loadFeedbackController, animated: true)
    }
    @IBAction func goAbout(_ sender: Any) {
        self.navigationDrawerController?.closeLeftView()
        let loadHelpController = UIStoryboard.loadHelpController()
        self.navigationController?.pushViewController(loadHelpController, animated: true)
    }
    
    @IBAction func goHome(_ sender: Any) {
        self.navigationDrawerController?.closeLeftView()
    }
}

//
//  AppUpdateViewController.swift
//  nthLink
//
//  Created by Vaneet Modgill on 26/12/24.
//

import UIKit

class AppUpdateViewController: AppBaseViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func updateAppButtonPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: AppConfigurations.getAppStoreURLForUpdate())!)
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

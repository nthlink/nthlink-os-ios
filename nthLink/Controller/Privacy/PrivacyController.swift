//
//  PrivacyController.swift
//  nthLink
//
//  Created by Vaneet Modgillon 6/29/23.
//

import UIKit

@available(iOS 15, *)
class PrivacyController: AppBaseViewController {
    @IBOutlet weak var tvPrivacy: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPrivacyTextView()
    }
    
    @IBAction func agreePrivacy(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: UserDefaultKeys.isPrivacyPolicyAccepted)
        let homeController = UIStoryboard.loadHomeViewController()
        let menuController = UIStoryboard.loadMenuController()
        let newViewController = RootView(rootViewController: homeController, leftViewController: menuController, rightViewController: nil)
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    @IBAction func goToAbout(_ sender: Any) {
        UIApplication.shared.open(URL(string: AppConfigurations.getHomeURL())!)
    }
    
    
    private func setupPrivacyTextView() {
        tvPrivacy.textColor = UIColor.black
        tvPrivacy.attributedText =  NSMutableAttributedString()
            .bold24("Privacy Policy\n")
            .normal12("\nnthLink does not collect personally identifiable information and does not track which websites or online services you visit. nthLink may use your IP address, your device’s default language, cookies, and basic information on your operating system information (Android or iOS) to customize the services that you receive. This allows us to locate the nearest servers that can best support your device.\n\n")
            .bold24("Term of Use\n")
            .normal12("\nBy accessing, downloading, or using nthLink, you are agreeing to the terms of services below. The Agreement is a binding contract between you and nthLink regarding your use of nthLink.\n\n")
            .bold12("License. ")
            .normal12("nthLink is made available by nthLink under the Apache 2.0 license.\n")
            .bold12("Assumption of Risk. ")
            .normal12("You may use nthLink and invite others to use nthLink only as permitted by law. We encourage you to check local laws and regulations before using nthLink.\n")
            .bold12("Your content. ")
            .normal12("Content that you upload, submit, store, send or receive through nthLink Servers (“Your Content”) is not uploaded or submitted to nthLink. We do not know what you are sending with nthLink.\n")
            .bold12("Copyright notices. ")
            .normal12("nthLink does not host or store any content that you access through nthLink Servers. Any notices of alleged copyright infringement or other legal notices relating to content hosted, stored, sent or received via nthLink Servers should be dealt with by you or directed to your Service Provider.")
    }
    
}

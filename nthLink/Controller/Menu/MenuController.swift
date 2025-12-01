//
//  MenuController.swift
//  nthLink
//
//  Created by RuiHua on 6/29/23.
//

import UIKit
import SwiftUI

@available(iOS 15, *)
class MenuController: AppBaseViewController {
    @IBOutlet private weak var updateAppButton: UIButton!
    @IBOutlet private weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkUpdateAppData()
    }
    
    private func checkUpdateAppData(){
        updateAppButton.isHidden = true
        guard let newsData = APIDataCacher.sharedInstance.getCacheData(forKey: .News) as? NewsData else { return }
        if newsData.currentVersions.count == 0 {return}
        let filterPlatformData = newsData.currentVersions[0].platforms.filter{$0.os == "ios"}
        if filterPlatformData.isEmpty {return}
        let appVersionFromAPI = (filterPlatformData.first?.version ?? "").replacingOccurrences(of: ".", with: "").replacingOccurrences(of: " ", with: "")
        let appVersion = (Utilities.appVersionNumber as? String ?? "").replacingOccurrences(of: ".", with: "")
        if appVersion < appVersionFromAPI {
            updateAppButton.isHidden = false
        }
    }
    
    private func setupData(){
        versionLabel.text = LocalizedStringEnum.about_version.localized + " " + (Utilities.appVersionNumber as? String ?? "")
    }
    
    @IBAction func goHelp(_ sender: Any) {
        UIApplication.shared.open(URL(string: AppConfigurations.getHelpURL())!)
    }
    
    @IBAction func goRate(_ sender: Any) {
        UIApplication.shared.open(URL(string: AppConfigurations.getAppStoreURL())!)
    }
    
    @IBAction func telegramButtonClicked(_ sender: Any) {
        UIPasteboard.general.string =  AppConfigurations.getTelegramID()
        self.showCommonAlert(title: LocalizedStringEnum.copiedText.localized, message: LocalizedStringEnum.telegramIdCopiedAlert.localized, controller: self)
    }
    
    @IBAction func privacyPolicyButtonClicked(_ sender: Any) {
        UIApplication.shared.open(URL(string: AppConfigurations.getPrivacyPolicyURL())!)
    }
    
    @IBAction func followUsButtonPress(_ sender: Any) {
        self.navigationDrawerController?.closeLeftView()
        let followUsPage = UIHostingController(rootView: FollowUsView())
        followUsPage.view.backgroundColor = AppColors.appCreamColor
        self.navigationController?.pushViewController(followUsPage, animated: true)
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
    
    @IBAction func openDiagnosticsScreen(_ sender: Any) {
        self.navigationDrawerController?.closeLeftView()
        let loadDiagnosticsViewController = UIStoryboard.loadDiagnosticsViewController()
        self.navigationController?.pushViewController(loadDiagnosticsViewController, animated: true)
    }
    
    @IBAction func updateAppButtonPressed(_ sender: Any) {
        self.navigationDrawerController?.closeLeftView()
        let loadAppUpdateViewController = UIStoryboard.loadAppUpdateViewController()
        self.navigationController?.pushViewController(loadAppUpdateViewController, animated: true)
    }
}

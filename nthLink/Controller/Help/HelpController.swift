//
//  HelpController.swift
//  nthLink
//
//  Created by RuiHua on 6/29/23.
//

import UIKit

class HelpController: UIViewController {
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var aboutUsdescriptionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInitialData()
    }
    
    @IBAction func goHome(_ sender: Any) {
        UIApplication.shared.open(URL(string: AppConfigurations.getHomeURL())!)
    }
    
    @IBAction func showMenu(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupInitialData(){
        aboutUsdescriptionLabel.attributedText = LocalizedStringEnum.about_text.localized.html2AttributedString
        aboutUsdescriptionLabel.minimumScaleFactor = 0.5
        aboutUsdescriptionLabel.adjustsFontSizeToFitWidth = true
        aboutUsdescriptionLabel.numberOfLines = 0
        aboutUsdescriptionLabel.font =  UIFont.systemFont(ofSize: 14)
        self.view.backgroundColor = AppColors.appBlueColor
    }

}

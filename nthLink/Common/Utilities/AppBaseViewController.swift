//
//  AppBaseViewController.swift
//  nthLink
//
//  Created by Vaneet Modgill on 17/02/24.
//

import Foundation
import UIKit

open class AppBaseViewController: UIViewController,AppBaseHandlable{
     
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view = Utilities.handleStatusbarForIncomingPhoneCall(view: self.view)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


protocol AppBaseHandlable {
    func displayAlertWithTitle(title:String, message:String, actionButtonTitle:String, controller:UIViewController)
    func showCommonAlert(message:String, controller:UIViewController)
}

extension AppBaseHandlable {
    //MARK:- Alert Method
    func displayAlertWithTitle(title:String, message:String, actionButtonTitle:String, controller:UIViewController){
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: actionButtonTitle, style: UIAlertAction.Style.default, handler: nil))
           controller.present(alert, animated: true, completion: nil)
       }
    
    func showCommonAlert(message:String, controller:UIViewController) {
        let alert = UIAlertController(title: LocalizedStringEnum.Notice.localized, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: LocalizedStringEnum.OK.localized, style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
}

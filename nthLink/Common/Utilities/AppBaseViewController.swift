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
    func showCommonAlert(title:String?, message:String, controller:UIViewController)
//    func showWebServiceError(error:STError, controller:UIViewController)
}
//
extension AppBaseHandlable {
    //MARK:- Alert Method
    func displayAlertWithTitle(title:String, message:String, actionButtonTitle:String, controller:UIViewController){
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: actionButtonTitle, style: UIAlertAction.Style.default, handler: nil))
           controller.present(alert, animated: true, completion: nil)
       }
    
    func showCommonAlert(title:String? = nil, message:String, controller:UIViewController) {
        let alert = UIAlertController(title: title ?? LocalizedStringEnum.Notice.localized, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: LocalizedStringEnum.OK.localized, style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
       
//     func showWebServiceError(error:STError, controller:UIViewController){
//           var message = error.description ?? Constant.NetworkError.generalMessage
//           if error.error.localizedDescription == STWebServiceError.networkNotReachable.localizedDescription {
//               message = Constant.NetworkError.networkNotReachable
//           }
//           let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
//           alert.addAction(UIAlertAction(title: LocalizedStringEnum.OK.localized, style: UIAlertAction.Style.default, handler: nil))
//           controller.present(alert, animated: true, completion: nil)
//       }
//       
//       
//      // MARK:- Progress Method(s)
//       
//    func homeButtonClicked(controller:UIViewController){
//           if controller.tabBarController?.selectedIndex == 0 {
//               for controller in controller.navigationController!.viewControllers {
//                   if controller.isKind(of: HomeScreenViewController.self){
//                       controller.navigationController!.popToViewController(controller, animated: true)
//                   }
//               }
//               
//           } else {
//               controller.tabBarController?.selectedIndex = 0
//               for controller in controller.navigationController!.viewControllers.reversed() {
//                   if controller.isKind(of: HomeScreenViewController.self){
//                       controller.navigationController!.popToViewController(controller, animated: true)
//                       return
//                   }
//               }
//               controller.navigationController?.popToRootViewController(animated: true)
//           }
//       }
}

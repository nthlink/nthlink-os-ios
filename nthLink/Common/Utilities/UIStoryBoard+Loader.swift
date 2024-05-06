//
//  UIStoryBoard+Loader.swift
//  nthLink
//
//  Created by Vaneet Modgill on 17/02/24.
//

import Foundation

import UIKit
fileprivate enum Storyboard : String {
    case main = "Main"
}

fileprivate extension UIStoryboard {
    static func loadFromMain(_ identifier: String) -> UIViewController {
        return load(from: .main, identifier: identifier)
    }

    static func load(from storyboard: Storyboard, identifier: String) -> UIViewController {
        let uiStoryboard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        return uiStoryboard.instantiateViewController(withIdentifier: identifier)
    }
}

// MARK:  MAIN/FEEDBACK/SEARCH/TIMELINE
extension UIStoryboard {
    
    static func loadHomeViewController()->HomeViewController {
        return loadFromMain(HomeViewController.className) as! HomeViewController
    }
    
    @available(iOS 15, *)
    static func loadMenuController() -> MenuController {
        return loadFromMain(MenuController.className) as! MenuController
    }
    
    @available(iOS 15, *)
    static func loadPrivacyController() -> PrivacyController {
        return loadFromMain(PrivacyController.className) as! PrivacyController
    }
    
    @available(iOS 15, *)
    static func loadFeedbackController() -> FeedbackController {
        return loadFromMain(FeedbackController.className) as! FeedbackController
    }
    
    @available(iOS 15, *)
    static func loadHelpController() -> HelpController {
        return loadFromMain(HelpController.className) as! HelpController
    }
    
    static func loadNewsController() -> NewsController {
        return loadFromMain(NewsController.className) as! NewsController
    }
    
}

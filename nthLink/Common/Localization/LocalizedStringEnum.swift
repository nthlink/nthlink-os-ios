//
//  LocalizedStringEnum.swift
//  nthLink
//
//  Created by Vaneet Modgill on 17/02/24.
//

import Foundation


enum LocalizedStringEnum:String {
    
    //Menu View Controller
    case menu_drawer_item_1
    case about_page_title
    case menu_drawer_item_4
    case feedback_page_title
    case menu_drawer_item_5
    case about_version
    case telegramIDText
    case copiedText
    case telegramIdCopiedAlert
    case followUsText
    case diagnosticPageTitle
    case UpdateAppMenu
    
    //Help View Controller
    case about_text
    case aboutVisitOurHomeText
    
    //Feedback View Controller
    case issue_categories_1
    case issue_categories_2
    case issue_categories_3
    case issue_categories_4
    case issue_categories_5
    case feedback_submit
    case feedback_submit_success_message
    case feedbackDescTextFieldInitialText
    case feedbackErrorSelectType
    case feedbackErrorAddDescription
    case feedbackDescEmailIDLabel
    case feedbackSubtext
    case feedbackSelectIssueButton
    
    // News View Controller
    case menu_web_item_3
    case menu_web_item_2
    case menu_web_item_1
    
    // General
    case somethingWentWrong
    case Notice
    case OK
    case Cancel
    case loading
    
    //HomeViewController
    case Disconnect
    case Connect
    case Connecting
    case Disconnecting
    case homeReadLatestNews
    case connectionQualityLabel
    
    //News View Controller
    case word_loading

    //privacy policy
    case privacyPolicyAgreeButton
    case privacyPolicyLearnMoreButton
    
    //FollowUs Page
    case visitButtonText
    
    //Diagnostics
    case diagnosticsStartButton
    case diagnosticsDescription
    case diagnosticsSuceessMessage
    case diagnosticsInternetError
    case diagnosticsStartDisconnectWarning
    
    case updateScreenLabel
    case updateScreenSubtext
    case updateScreenUpdateNowButtonText

    //Connectivity Health Check
    case connectivityWarning
    case connectivityError

    //VPN Permission
    case vpnPermissionDeniedTitle
    case vpnPermissionDeniedMessage
    case vpnConfigurationErrorTitle
    case vpnConfigurationErrorMessage
    case tryAgain


    var localized:String{
        return self.rawValue.localized
    }
    
}


extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String
    {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: "**\(self)**", comment: "")
    }
}

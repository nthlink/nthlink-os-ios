//
//  Common.swift
//  nthLink
//
//  Created by Vaneet Modgill on 17/02/24.
//

import UIKit
import SwiftUI


var isFromFeedback = false

struct UserDefaultKeys {
    static let isPrivacyPolicyAccepted = "Accept_privacy"
}

struct AppColors {
    static let appBlueColor: UIColor = UIColor.init(red: 0.0, green: 97/255, blue: 1.0, alpha: 1)
    static let appCreamColor: UIColor = UIColor.init(red: 242/255, green: 234/255, blue: 214/255, alpha: 1)
    static let appCreamColor_swiftUI: Color = Color(red: 242 / 255, green: 234 / 255, blue: 214 / 255)
    static let appBlueColor_swiftUI: Color = Color(red: 0, green: 97 / 255, blue: 255 / 255)
    static let newsListBackgroundCreamColor:UIColor = UIColor.init(red: 250/255, green: 239/255, blue: 213/255, alpha: 0.45)
}


struct AssetImagesString {
    static let appLogoWhite = "logo_white"
    static let appLogoBlue = "logo_blue"
    static let menuBlue = "ic_menu_blue"
    static let menuBlack = "menu_black"
}


enum ReportEventType:Int {
    case LandingPageOpen = 1
    case TopHeadlineWebViewCellOpen = 2
    case ClickOnNewsHeadline = 3
}

struct InAppEvents {
    static let homeLaunched = "homeLaunched"
}


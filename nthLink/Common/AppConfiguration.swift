//
//  AppConfiguration.swift
//  nthLink
//
//  Created by Vaneet Modgill on 17/02/24.
//

import Foundation



class AppConfigurations {
    
 
    static func getHomeURL() -> String{
      return  "https://www.nthlink.com/"
    }
    
    static func getHelpURL() -> String{
        return "https://www.nthlink.com/#faq"
    }
    
    static func getAppStoreURL() -> String{
        let appID = ""
        return "itms-apps://itunes.apple.com/app/id\(appID)?mt=8&action=write-review"
    }
    
    static func getAppStoreURLForUpdate() -> String{
        let appID = ""
        return "itms-apps://itunes.apple.com/app/id\(appID)?mt=8"
    }

    static func getPrivacyPolicyURL() -> String{
        return "https://www.nthlink.com/policies/"
    }
    
    static func getTelegramID() -> String {
        return "@nthLinkVPN"
    }
  
    
}


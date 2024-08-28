//
//  Utilities+Cacher.swift
//  nthLink
//
//  Created by Vaneet Modgill on 29/02/24.
//

import UIKit

enum CacheKey:String, EnumCollection{
    case News
}

class APIDataCacher: NSObject {

    static let sharedInstance = APIDataCacher()

    //#MARK: Server settings
    func cacheData(forKey:CacheKey,data:AnyObject){
        switch forKey {
        case .News:
            do {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(data as! NewsData)
                UserDefaults.standard.set(encoded, forKey: forKey.rawValue)
            } catch {
                print("Failed to save NewsData to UserDefaults: \(error)")
            }
        }
    }
    
    func getCacheData(forKey:CacheKey)->AnyObject?{
        if let data  =  UserDefaults.standard.data(forKey: forKey.rawValue) {
            switch forKey {
            case .News:
                do {
                    let decoder = JSONDecoder()
                    let decoded = try decoder.decode(NewsData.self, from: data)
                    return decoded
                } catch {
                    print("Failed to load NewsData from UserDefaults: \(error)")
                    return nil
                }
            }
        }
        return nil
    }

}



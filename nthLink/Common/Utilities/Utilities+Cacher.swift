//
//  Utilities+Cacher.swift
//  nthLink
//
//  Created by Vaneet Modgill on 29/02/24.
//

import UIKit

enum CacheKey:String, EnumCollection{
    case News
    case events
}

class APIDataCacher: NSObject {

    static let sharedInstance = APIDataCacher()

    //#MARK: Server settings


    func cacheData(forKey:CacheKey,data:AnyObject){
        DispatchQueue.global(qos: .default).async {
            switch forKey {
            case .News:
                do {
                    let encoder = JSONEncoder()
                    let encoded = try encoder.encode(data as! NewsData)
                    UserDefaults.standard.set(encoded, forKey: forKey.rawValue)
                } catch {
                    print("Failed to save NewsData to UserDefaults: \(error)")
                }
            case .events:
                do {
                    var eventArray = [EventModel]()
                    if let tempEventData = self.getCacheData(forKey: forKey) {
                        eventArray = tempEventData as? [EventModel] ?? [EventModel]()
                    }
                    eventArray.append(contentsOf: data as! [EventModel])
                    let encoder = JSONEncoder()
                    let encoded = try encoder.encode(eventArray)
                    UserDefaults.standard.set(encoded, forKey: forKey.rawValue)
                } catch {
                    print("Failed to save events to UserDefaults: \(error)")
                }
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
            case .events:
                do {
                    let decoder = JSONDecoder()
                    let decoded = try decoder.decode([EventModel].self, from: data)
                    return decoded as AnyObject
                } catch {
                    print("Failed to load events from UserDefaults: \(error)")
                    return nil
                }
            }
        }
        return nil
    }
    
    func removeCacheData(forKey:CacheKey) {
        UserDefaults.standard.removeObject(forKey: forKey.rawValue)
    }


}



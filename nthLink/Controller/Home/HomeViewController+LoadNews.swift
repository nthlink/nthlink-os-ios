//
//  HomeViewController+LoadNews.swift
//  nthLink
//
//  Created by Vaneet Modgill on 24/02/24.
//

import UIKit
import SwiftyJSON


extension HomeViewController {

    func getServerConfig() {
        var requstJsonData = Data()
        if let path = Bundle.main.url(forResource: "News", withExtension: "json") {
            do {
                let data = try Data(contentsOf: path)
                requstJsonData = data
            } catch let error{
                print("!!!\(error)")
                
            }
        }
        do {
            let tempNewsData = try? JSONDecoder().decode(NewsData.self, from: requstJsonData)
            let servers = tempNewsData?.servers?.shuffled() ?? []
            for i in servers {
                let serverConf = "Proxy = trojan, \(i.address), \(String(i.port!)), password=\(i.password!), sni=\(i.host), ws=true, ws-path=\(i.path)"
                let newConf = config + serverConf
                UserDefaults.init(suiteName: appGroup)?.set(newConf, forKey: configKey)
            }
            newsData = tempNewsData ?? NewsData()
            APIDataCacher.sharedInstance.cacheData(forKey: .News, data: newsData as AnyObject)
            try vpnManager.connection.startVPNTunnel()
        } catch let error as NSError  {
            print(error.description)
        }
    }
    
}

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
        // Load News.json from bundle (nthLinkOpenSource approach)
        guard let path = Bundle.main.url(forResource: "News", withExtension: "json") else {
            DispatchQueue.main.async {
                self.showStatus(status: .disconnected)
            }
            showCommonAlert(message: LocalizedStringEnum.somethingWentWrong.localized, controller: self)
            print("News.json file not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: path)
            let tempNewsData = try? JSONDecoder().decode(NewsData.self, from: data)
            newsData = tempNewsData
            if tempNewsData?.use_custom_config ?? false{
                let config = """
                             [General]
                             tun-fd = {{TUN-FD}}
                             
                             """
                let customConfig = tempNewsData?.custom_config?.replacingOccurrences(of: "[General]\n", with: config)
                UserDefaults.init(suiteName: appGroup)?.set(customConfig, forKey: configKey)
            } else {
                for i in tempNewsData?.servers ?? [] {
                    if  !i.ips.isEmpty {
                        let ipsList = i.ips.joined(separator: ", ")
                        let wsHost = i.wsHost.isEmpty == false ? i.wsHost : i.host
                        let ips = "ips = \(ipsList)"
                        let serverConf = "Proxy = trojan, ips, \(String(i.port)), password=\(i.password), sni=\(i.host), ws=true, ws-path=\(i.path), ws-host=\(wsHost)"
                        let newConf = config + serverConf  + "\n" + "[Host]\n" + ips
                        UserDefaults.init(suiteName: appGroup)?.set(newConf, forKey: configKey)
                    } else {
                        let wsHost = i.wsHost.isEmpty == false ? i.wsHost : i.host
                        let serverConf = "Proxy = trojan, \(i.address), \(String(i.port)), password=\(i.password), sni=\(i.host), ws=true, ws-path=\(i.path), ws-host=\(wsHost)"
                        let newConf = config + serverConf
                        UserDefaults.init(suiteName: appGroup)?.set(newConf, forKey: configKey)
                    }
                }
            }
            staticValueIndicatorView.isHidden = !(newsData?.static ?? false)

            // Determine the number of top news items to show (maximum 4 or less if there aren't enough)
            let totalHeadlineCount = newsData?.headlineNews?.count ?? 0
            let topNewsCount = min(4, totalHeadlineCount)

            // Separate pinned and non-pinned news items
            let pinnedNews = newsData?.headlineNews?.filter { $0.pinToTop == true } ?? []
            let nonPinnedNews = newsData?.headlineNews?.filter { $0.pinToTop != true } ?? []

            var topHeadlineNews = [HeadlineNewsData]()

            // 1. Add pinned news to the top list.
            if !pinnedNews.isEmpty {
                if pinnedNews.count >= topNewsCount {
                    topHeadlineNews.append(contentsOf: Array(pinnedNews.prefix(topNewsCount)))
                } else {
                    topHeadlineNews.append(contentsOf: pinnedNews)
                    let remainingCount = topNewsCount - pinnedNews.count

                    // 2. Randomly select additional news from non-pinned items if needed.
                    if remainingCount > 0 && nonPinnedNews.count >= remainingCount {
                        if let randomIndices = generateUniqueRandomNumbers(count: remainingCount, min: 0, max: nonPinnedNews.count - 1, customNumber: nil) {
                            for index in randomIndices {
                                topHeadlineNews.append(nonPinnedNews[index])
                            }
                        }
                    } else if remainingCount > 0 {
                        // If there are fewer non-pinned items than needed, add all
                        topHeadlineNews.append(contentsOf: nonPinnedNews)
                    }
                }
            } else {
                // No pinned news available; randomly select from all headline news
                if let randomIndices = generateUniqueRandomNumbers(count: topNewsCount, min: 0, max: totalHeadlineCount - 1, customNumber: nil) {
                    for index in randomIndices {
                        if let newsItem = newsData?.headlineNews?[index] {
                            topHeadlineNews.append(newsItem)
                        }
                    }
                }
            }

            // Update the newsData with the selected top headline news
            newsData?.topHeadlineNews = topHeadlineNews

            APIDataCacher.sharedInstance.cacheData(forKey: .News, data: newsData as AnyObject)
            try vpnManager.connection.startVPNTunnel()
        } catch let error as NSError  {
            print(error.description)
        }
    }

    
    func generateUniqueRandomNumbers(count: Int, min: Int, max: Int, customNumber: Int?) -> [Int]? {
        guard max - min + 1 >= count else {
            return nil
        }
        
        var numbers = Set<Int>()
        
        // If a custom number is provided and within the range, add it.
        if let custom = customNumber, custom >= min, custom <= max {
            numbers.insert(custom)
        }
        
        // Generate random numbers until the set reaches the desired count.
        while numbers.count < count {
            let randomNumber = Int.random(in: min...max)
            numbers.insert(randomNumber)
        }
        
        // If a custom number was provided, ensure it is at the first index.
        var result = Array(numbers)
        if let custom = customNumber, custom >= min, custom <= max {
            result.removeAll { $0 == custom }
            result.insert(custom, at: 0)
        }
        
        return result
    }
    
}



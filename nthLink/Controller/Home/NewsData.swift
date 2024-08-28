//
//  NewsData.swift
//  nthLink
//
//  Created by Vaneet Modgill on 28/02/24.
//

import Foundation

// MARK: - Welcome
class NewsData: Codable {
    var notifications: [NotificationData]?
    var headlineNews: [HeadlineNewsData]?
    var redirectURL: String?
    var servers: [Servers]?


    enum CodingKeys: String, CodingKey {
        case headlineNews, notifications
        case redirectURL = "redirectUrl"
        case servers = "servers"

    }
    init() {
        
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.notifications = try container.decodeIfPresent([NotificationData].self, forKey: .notifications)
        self.headlineNews = try container.decodeIfPresent([HeadlineNewsData].self, forKey: .headlineNews)
        self.redirectURL = try container.decodeIfPresent(String.self, forKey: .redirectURL)
        self.servers = try container.decodeIfPresent([Servers].self, forKey: .servers)
    }
}

// MARK: - HeadlineNew
class HeadlineNewsData: Codable {
    var url: String?
    var title, image: String?
    init() {
        
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
    }
}

// MARK: - Notification
class NotificationData: Codable {
    var title: String?
    var url: String?
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
    }
}

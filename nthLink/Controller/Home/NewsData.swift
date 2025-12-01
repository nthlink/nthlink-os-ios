//
//  NewsData.swift
//  nthLink
//
//  Created by Vaneet Modgill on 28/02/24.
//

import Foundation

// MARK: - Welcome
class NewsData: Codable {
    var obfuInterval: String?
    var notifications: [NotificationData]?
    var headlineNews: [HeadlineNewsData]?
    var topHeadlineNews = [HeadlineNewsData]()
    var redirectURL: String?
    var obfuExcludeHost: String?
    var dataString: String?
    var obfuUrls: [String]?
    var obfuMax: String?
    var servers: [ServerData]?
    let `static`: Bool?
    var use_custom_config: Bool?
    var custom_config:String?
    var currentVersions: [CurrentVersionData] = []
    


    enum CodingKeys: String, CodingKey {
        case obfuInterval, notifications, headlineNews, topHeadlineNews, use_custom_config, custom_config
        case redirectURL = "redirectUrl"
        case obfuExcludeHost, obfuUrls, obfuMax, servers
        case `static` = "static"
        case dataString = "data"
        case currentVersions = "current_versions"

    }

    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.obfuInterval = try container.decodeIfPresent(String.self, forKey: .obfuInterval)
        self.notifications = try container.decodeIfPresent([NotificationData].self, forKey: .notifications)
        self.headlineNews = try container.decodeIfPresent([HeadlineNewsData].self, forKey: .headlineNews)
        self.redirectURL = try container.decodeIfPresent(String.self, forKey: .redirectURL)
        self.obfuExcludeHost = try container.decodeIfPresent(String.self, forKey: .obfuExcludeHost)
        self.dataString = try container.decodeIfPresent(String.self, forKey: .dataString)
        self.obfuUrls = try container.decodeIfPresent([String].self, forKey: .obfuUrls)
        self.obfuMax = try container.decodeIfPresent(String.self, forKey: .obfuMax)
        self.topHeadlineNews = try container.decodeIfPresent([HeadlineNewsData].self, forKey: .topHeadlineNews) ?? [HeadlineNewsData]()
        self.servers = try container.decodeIfPresent([ServerData].self, forKey: .servers) ?? [ServerData]()
        self.use_custom_config = try container.decodeIfPresent(Bool.self, forKey: .use_custom_config)
        self.custom_config = try container.decodeIfPresent(String.self, forKey: .custom_config)
        self.`static` = try container.decodeIfPresent(Bool.self, forKey: .static)
        self.currentVersions = try container.decodeIfPresent([CurrentVersionData].self, forKey: .currentVersions) ?? []
        
    }
}

// MARK: - HeadlineNew
class HeadlineNewsData: Codable {
    var url: String?
    var pinToTop: Bool?
    var title, image: String?
    init() {
        
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.pinToTop = try container.decodeIfPresent(Bool.self, forKey: .pinToTop)
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

// MARK: - Server
class ServerData: Codable {
    var host: String = ""
    var port: String = ""
    var path: String = ""
    var ws: Bool = true
    var `protocol`: String = ""
    var address: String = ""
    var password: String = ""
    var ips: [String] = []
    var wsHost: String = ""

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.host = try container.decodeIfPresent(String.self, forKey: .host) ?? ""
        self.port = try container.decodeIfPresent(String.self, forKey: .port) ?? ""
        self.path = try container.decodeIfPresent(String.self, forKey: .path) ?? ""
        self.ws = try container.decodeIfPresent(Bool.self, forKey: .ws) ?? false
        self.protocol = try container.decodeIfPresent(String.self, forKey: .protocol) ?? ""
        self.address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        self.password = try container.decodeIfPresent(String.self, forKey: .password) ?? ""
        self.ips = try container.decodeIfPresent([String].self, forKey: .ips) ?? []
        self.wsHost = try container.decodeIfPresent(String.self, forKey: .wsHost) ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case host = "sni"
        case port = "port"
        case path = "ws_path"
        case ws = "ws"
        case `protocol` = "protocol"
        case address = "host"
        case password = "password"
        case ips = "ips"
        case wsHost = "ws_host"
    }
}


// MARK: - Current Version
class CurrentVersionData: Codable {
    var appName: String = ""
    var platforms: [PlatformData] = []


    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.appName = try container.decodeIfPresent(String.self, forKey: .appName) ?? ""
        self.platforms = try container.decodeIfPresent([PlatformData].self, forKey: .platforms) ?? []
    }
    
    enum CodingKeys: String, CodingKey {
        case appName = "app_name"
        case platforms = "platforms"

    }
}

class PlatformData: Codable {
    var os: String = ""
    var version: String = ""


    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.os = try container.decodeIfPresent(String.self, forKey: .os) ?? ""
        self.version = try container.decodeIfPresent(String.self, forKey: .version) ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case os = "os"
        case version = "version"

    }
}


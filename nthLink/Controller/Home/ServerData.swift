//
//  ServerData.swift
//  nthLink
//
//  Created by Vaneet Modgill on 04/03/24.
//

import Foundation
var servers: [Servers] = []


public struct Servers: Codable {
    let host: String
    let port: String?
    let path: String
    let ws: Bool
    let `protocol`: String
    let username: String?
    let address: String
    let password: String?
    let method: String?
    
    enum CodingKeys: String, CodingKey {
        case host = "sni"
        case port = "port"
        case path = "ws_path"
        case ws = "ws"
        case `protocol` = "protocol"
        case username = "username"
        case address = "host"
        case password = "password"
        case method = "encrypt_method"
    }
}

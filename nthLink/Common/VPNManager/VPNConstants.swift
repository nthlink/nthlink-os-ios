//
//  VPNConstants.swift
//  nthLink
//
//  Created by Vaneet Modgill on 17/02/24.
//

import Foundation
import NetworkExtension

var config = """
[General]
dns-server = 1.1.1.1
loglevel = debug
always-real-ip = *
routing-domain-resolve = false
tun-fd = {{TUN-FD}}
[Env]
HTTP_USER_AGENT = nthlink
[Proxy]

"""

var vpnManager = NEVPNManager.shared()

let appGroup = "group.com.nthlink.ios.client"
let configKey = "CONFIG_KEY"

struct VPNConstants {
    static let localizedDescription = "nthLink"
    static let serverAddress = "nthLink"
}


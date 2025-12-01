//
//  ReportObject.swift
//  TunnelRaySampleApp
//
//  Created by RuiHua on 2023/8/1.
//

import Foundation
import SwiftyJSON

struct EventModel: Codable {
    let url: String
    let utcTime: String
    let source: Int

    public static func createEvent(url:String,type:ReportEventType) -> EventModel{
      return  EventModel(url: url, utcTime: Date.getCurrentDate(), source: type.rawValue)
    }
    
    public static func getEventString(events:[EventModel]) -> String {
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(events)
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
        return jsonString ?? ""
    }
}

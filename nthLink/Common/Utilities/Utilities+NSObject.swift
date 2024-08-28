//
//  Utilities+NSObject.swift
//  nthLink
//
//  Created by Vaneet Modgill on 17/02/24.
//

import Foundation
extension NSObject {
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }
    
    class var className: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
}

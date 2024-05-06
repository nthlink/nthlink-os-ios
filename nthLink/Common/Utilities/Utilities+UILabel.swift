//
//  Utilities+UILabel.swift
//  nthLink
//
//  Created by Vaneet Modgill on 17/02/24.
//

import UIKit

extension UILabel {

    @IBInspectable public var localizeKey: String {
        get {
            return ""
        }
        set {
            if newValue != "" {
                self.text = LocalizedStringEnum(rawValue: newValue)?.localized
            }
        }
    }

}

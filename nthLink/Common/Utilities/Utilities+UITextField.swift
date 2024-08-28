//
//  Utilities+UITextField.swift
//  nthLink
//
//  Created by Vaneet Modgill on 17/02/24.
//

import UIKit

// MARK: - Properties
public extension UITextField {

    var isEmpty: Bool {
        return text?.isEmpty == true
    }

    var trimmedText: String? {
        return text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var hasValidEmail: Bool {
        return text!.range(of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
                           options: String.CompareOptions.regularExpression,
                           range: nil, locale: nil) != nil
    }
    
    @IBInspectable var localizeKey: String {
        get {
            return ""
        }
        set {
            if newValue != "" {
                self.text = LocalizedStringEnum(rawValue: newValue)?.localized
            }
        }
    }

    @IBInspectable var localizePlaceholderKey: String {
        get {
            return ""
        }
        set {
            if newValue != "" {
                self.placeholder = LocalizedStringEnum(rawValue: newValue)?.localized
            }
        }
    }
  
}

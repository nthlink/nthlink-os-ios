//
//  Utilities+UIButton.swift
//  nthLink
//
//  Created by Vaneet Modgill on 17/02/24.
//

import UIKit


//MARK:- Button Theme
extension UIButton{
   
    @IBInspectable public var localizeKey: String {
        get {
            return ""
        }
        set {
            if newValue != "" {
                self.setTitle(LocalizedStringEnum(rawValue: newValue)?.localized, for: .normal)
            }
        }
    }
    
   
    
    func setImageColor(color: UIColor) {
        let templateImage = self.imageView?.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.imageView?.image = templateImage
        self.imageView?.tintColor = color
        self.tintColor = color
    }

    
    
  
    
}


//
//  Utilities+StatusBar.swift
//  nthLink
//
//  Created by Vaneet Modgill on 17/02/24.
//

import UIKit

extension(Utilities){
    static func handleStatusbarForIncomingPhoneCall(view:UIView)->UIView{
        view.autoresizesSubviews = true
        view.autoresizingMask =  UIView.AutoresizingMask.flexibleTopMargin
        view.autoresizingMask = UIView.AutoresizingMask.flexibleHeight;
        return view
    }
    
}

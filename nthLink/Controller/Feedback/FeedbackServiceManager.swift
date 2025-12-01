//
//  FeedbackServiceManager.swift
//  nthLink
//
//  Created by Vaneet Modgill on 17/02/24.
//

import UIKit

protocol FeedbackServiceManagerDelegate:AnyObject {
    func feedbackServiceManagerDidSuccessfulySubmitFeedback(feedbackServiceManager:FeedbackServiceManager)
    func feedbackServiceManagerDidFailToSendFeedback(feedbackServiceManager:FeedbackServiceManager)
}


class FeedbackServiceManager {
    var selectedFeedbackErrorType = ""
    var dropperItemList = [LocalizedStringEnum.issue_categories_1.localized, LocalizedStringEnum.issue_categories_2.localized, LocalizedStringEnum.issue_categories_3.localized, LocalizedStringEnum.issue_categories_4.localized, LocalizedStringEnum.issue_categories_5.localized]
    weak var delegate:FeedbackServiceManagerDelegate?
    
    @available(iOS 15, *)
    func submitFeedback(emailID:String?, description:String?){
        // Hardcoded success response (nthLinkOpenSource approach)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.delegate?.feedbackServiceManagerDidSuccessfulySubmitFeedback(feedbackServiceManager: self)
        }
    }
}

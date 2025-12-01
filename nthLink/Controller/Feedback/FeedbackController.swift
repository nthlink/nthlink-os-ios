//
//  FeedbackController.swift
//  nthLink
//
//  Created by RuiHua on 7/12/23.
//

import UIKit
import Dropper

@available(iOS 15, *)
class FeedbackController: AppBaseViewController {
    
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var btType: UIButton!
    private var dropper:Dropper?
    private let descTextFieldInitialText = LocalizedStringEnum.feedbackDescTextFieldInitialText.localized
    private var serviceManager = FeedbackServiceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.serviceManager.delegate = self
        self.setupInitialData()
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectType(_ sender: Any) {
        if dropper!.status == .hidden {
            dropper!.showWithAnimation(0.15, options: Dropper.Alignment.left, button: btType)
            return
        }
        dropper!.hideWithAnimation(0.1)
    }
    
    @IBAction func trySubmit(_ sender: Any) {
        if serviceManager.selectedFeedbackErrorType == "" {
            showCommonAlert(message: LocalizedStringEnum.feedbackErrorSelectType.localized, controller: self)
            return
        }
        if tvDescription.text == "" || tvDescription.text == descTextFieldInitialText{
            showCommonAlert(message: LocalizedStringEnum.feedbackErrorAddDescription.localized, controller: self)
            return
        }
        self.serviceManager.submitFeedback(emailID: tfEmail.text, description: tvDescription.text)
    }
    
    private func setupInitialData(){
        self.view.backgroundColor = AppColors.appBlueColor
        setupDropper()
        tvDescription.text = descTextFieldInitialText
        tvDescription.textColor = UIColor(rgb: 0x9f9f9f)
        tvDescription.delegate = self
        tvDescription.backgroundColor = .white
    }
    
    private func setupDropper(){
        dropper = Dropper(width: self.view.frame.width - 50, height: 260)
        dropper!.items = serviceManager.dropperItemList
        dropper!.theme = Dropper.Themes.white
        dropper!.delegate = self
        dropper!.cornerRadius = 10
        dropper!.dividerColor = UIColor.white
        dropper!.dividerThickness = 0
        dropper!.isDividerHidden = true
        dropper!.borderColor = UIColor.lightGray
    }
}


@available(iOS 15, *)
extension FeedbackController: DropperDelegate {
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        serviceManager.selectedFeedbackErrorType = contents
        btType.setTitle(contents, for: .normal)
    }
}

@available(iOS 15, *)
extension FeedbackController:UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == descTextFieldInitialText {
            tvDescription.text = nil
            tvDescription.textColor = UIColor.black
        }
    }
    
}

@available(iOS 15, *)
extension FeedbackController:FeedbackServiceManagerDelegate{
    func feedbackServiceManagerDidSuccessfulySubmitFeedback(feedbackServiceManager:FeedbackServiceManager) {
        isFromFeedback = true
        let alert = UIAlertController(title: LocalizedStringEnum.Notice.localized, message: LocalizedStringEnum.feedback_submit_success_message.localized, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: LocalizedStringEnum.OK.localized, style: UIAlertAction.Style.default, handler: {_ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func feedbackServiceManagerDidFailToSendFeedback(feedbackServiceManager:FeedbackServiceManager) {
        self.showCommonAlert(message: LocalizedStringEnum.somethingWentWrong.localized, controller: self)
    }
}

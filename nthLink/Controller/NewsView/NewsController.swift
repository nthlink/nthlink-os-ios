//
//  NewsController.swift
//  nthLink
//
//  Created by RuiHua on 7/17/23.
//

import UIKit
import WebKit

class NewsController: UIViewController {
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var ivMore: UIImageView!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var btBack: UIButton!
    @IBOutlet weak var shareLinkView: UIView!
    @IBOutlet weak var openSafariView: UIView!
    @IBOutlet weak var copyLinkView: UIView!
    @IBOutlet weak var loadingWrapView: UIView!
    
    var newsURL = ""
    var isMenuShow = false
    let observerValue = "estimatedProgress"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInitialData()
        self.webview.addObserver(self, forKeyPath: observerValue, options: .new, context: nil);
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == observerValue {
            let percent = round(self.webview.estimatedProgress * 100)
            lbStatus.text = LocalizedStringEnum.word_loading.localized + "(\(percent)%)"
            //self.progressView.progress = Float(self.webView.estimatedProgress);
            if self.webview.estimatedProgress > 0.8 {
                newsView.isHidden = false
                loadingView.isHidden = true
            }
        }
    }
    
    private func setupInitialData(){
        self.cleanWebViewCookies { [weak self] in
            self?.webview.navigationDelegate = self
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                if let url =  URL(string: self?.newsURL ?? "") {
                    self?.webview.load(URLRequest(url:url))
                }
            })
            self?.showNewsView(isShow: false)
            self?.lbStatus.text = LocalizedStringEnum.word_loading.localized
            self?.setupMenuView()
        }
    }

    
    func cleanWebViewCookies(completion: @escaping () -> Void) {
        let dataTypes = Set([WKWebsiteDataTypeCookies])
        let dateFrom = Date(timeIntervalSince1970: 0)
        
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: dateFrom) {
            print("WKWebView cookies cleared.")
            completion()
        }
    }
    
    private func showNewsView(isShow:Bool){
        newsView.isHidden = !isShow
        loadingView.isHidden = isShow
    }
    
    private func setupMenuView(){
        ivMore.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        let menuGesture = UITapGestureRecognizer(target: self, action:  #selector(showMenu))
        ivMore.isUserInteractionEnabled = true
        ivMore.addGestureRecognizer(menuGesture)
        ivMore.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        let copyGesture = UITapGestureRecognizer(target: self, action:  #selector(copyLink))
        copyLinkView.isUserInteractionEnabled = true
        copyLinkView.addGestureRecognizer(copyGesture)
        let openSafariGesture = UITapGestureRecognizer(target: self, action:  #selector(openSafari))
        openSafariView.isUserInteractionEnabled = true
        openSafariView.addGestureRecognizer(openSafariGesture)
        let shareGesture = UITapGestureRecognizer(target: self, action:  #selector(shareLink))
        shareLinkView.isUserInteractionEnabled = true
        shareLinkView.addGestureRecognizer(shareGesture)
    }
    
    @objc func shareLink() {
        menuView.isHidden = true
        isMenuShow = false
        
        if let urlStr = NSURL(string:newsURL) {
            let objectsToShare = [urlStr]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popup = activityVC.popoverPresentationController {
                    popup.sourceView = self.view
                    popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
                }
            }

            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @objc func openSafari() {
        menuView.isHidden = true
        isMenuShow = false
        if let url = URL(string: newsURL) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func copyLink() {
        menuView.isHidden = true
        isMenuShow = false
        UIPasteboard.general.string = newsURL
    }
    
    @objc func showMenu() {
        if isMenuShow {
            menuView.isHidden = true
        } else {
            menuView.isHidden = false
        }
        isMenuShow = !isMenuShow
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
  
}



extension NewsController:WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        print("Webview : Loaded success!")
        newsView.isHidden = false
        loadingView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        print("Webview : Loaded failed!")
        newsView.isHidden = false
        loadingView.isHidden = true
    }
}

//
//  NewsTopHeadingTableViewCell.swift
//  nthLink
//
//  Created by Vaneet Modgill on 28/02/24.
//

import UIKit
import WebKit

protocol NewsTopHeadingTableViewCellDelegate: AnyObject {
    func newsTopHeadingTableViewCell(_ cell: NewsTopHeadingTableViewCell, didClickOpenNewsWith url: String, type: ReportEventType)
}

class NewsTopHeadingTableViewCell: UITableViewCell, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var snapshotImageView: UIImageView!
    @IBOutlet weak var ivMore: UIImageView!
    
    weak var delegate: NewsTopHeadingTableViewCellDelegate?
    private var data: HeadlineNewsData?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showNews))
        ivMore.isUserInteractionEnabled = true
        ivMore.addGestureRecognizer(tapGestureRecognizer)
        webView.navigationDelegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupData(data: HeadlineNewsData?) {
        snapshotImageView.image = nil;
        self.snapshotImageView.isHidden = true
        self.data = data
        guard let urlString = data?.url, let url = URL(string: urlString) else {
            return
        }
        ImageCacher.shared.getCacheImage(cacheKey: urlString) { [weak self] image in
            if let image = image {
                self?.snapshotImageView.image = image
                self?.snapshotImageView.isHidden = false
            }
            self?.webView.load(URLRequest(url: url))
        }
    }
    
    @IBAction func newsButtonClick(_ sender: Any) {
        self.delegate?.newsTopHeadingTableViewCell(self, didClickOpenNewsWith: self.data?.url ?? "", type: .ClickOnNewsHeadline)
    }
    
    @objc func showNews() {
        self.delegate?.newsTopHeadingTableViewCell(self, didClickOpenNewsWith: self.data?.url ?? "", type: .ClickOnNewsHeadline)
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let javascript = "document.body.style.zoom = '55%';"
        webView.evaluateJavaScript(javascript, completionHandler: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.snapshotImageView.isHidden = true
            let config = WKSnapshotConfiguration()
            config.rect = webView.bounds
            webView.takeSnapshot(with: config) { [weak self] image, error in
                guard let self = self, let urlString = self.data?.url else { return }
                if let image = image {
                    ImageCacher.shared.cacheImage(image, cacheKey: urlString)
                }
            }
        })
    
    }
}

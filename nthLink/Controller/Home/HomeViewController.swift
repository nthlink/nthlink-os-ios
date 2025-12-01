//
//  HomeViewController.swift
//  nthLink
//
//  Created by Vaneet Modgill on 13/02/24.
//

import UIKit
import NetworkExtension
import WebKit

class HomeViewController: AppBaseViewController {
    @IBOutlet weak var btNews: UIButton!
    @IBOutlet weak var btMenu: UIButton!
    @IBOutlet weak var ivConnect: UIImageView!
    @IBOutlet weak var btConnect: UIButton!
    @IBOutlet weak var logoImageStackView: UIStackView!
    @IBOutlet weak var newsTable: UITableView!
    @IBOutlet weak var viewBottomTap: UIImageView!
    @IBOutlet weak var connectButtonView: UIView!
    @IBOutlet weak var heightConnectButtonView: NSLayoutConstraint!
    @IBOutlet weak var connectButtonSubView: UIView!
    @IBOutlet weak var staticValueIndicatorView: UIView!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var connectionQualityLabel: UILabel!
    @IBOutlet weak var newsOverlayView: UIButton!
    
    var vpnStatus:NEVPNStatus = .disconnected
    var isNewsCalled = false
    var isShowBottomView = true {
        didSet {
            if isShowBottomView && vpnStatus == .connected {
                newsOverlayView.isHidden = false
                reloadTopNews()
            } else {
                newsOverlayView.isHidden = true
            }
        }
    }
    var newsData:NewsData?
    private let openedConnectButtonViewHeightConnected:CGFloat = 194
    private let openedConnectButtonViewHeightDisconnected:CGFloat = 126
    private let closedConnectButtonViewHeight:CGFloat = 40

    // Computed property for dynamic height based on connection status
    private var openedConnectButtonViewHeight: CGFloat {
        return vpnStatus == .connected ? openedConnectButtonViewHeightConnected : openedConnectButtonViewHeightDisconnected
    }

    // Connectivity monitoring properties
    var connectivityTimer: Timer?
    var currentConnectivityState: ConnectivityState = .healthy

    // Emoji slider for connection quality
    var emojiSlider: EmojiSlider?

    // VPN configuration state
    var isVPNConfigurationReady = false

    override func viewDidLoad() {
        super.viewDidLoad()
//        ImageCacher.shared.clearCache()
        setupInitialData()
        self.updateVpnStatus()

        // Set initial height based on VPN status
        if vpnStatus == .connected {
            self.heightConnectButtonView.constant = closedConnectButtonViewHeight
        } else {
            self.heightConnectButtonView.constant = openedConnectButtonViewHeight
        }

        self.createVPNConfiguration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        appCameToForeground()
        if (vpnStatus == .connected) && isFromFeedback {
            isFromFeedback = false
                self.heightConnectButtonView.constant = closedConnectButtonViewHeight
                self.view.layoutIfNeeded()
            isShowBottomView = false
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    
   deinit {
       NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: vpnManager.connection)
       stopConnectivityMonitoring()
   }
    
    @IBAction func goNewsPage(_ sender: Any ) {
        let newsMainPageURL = newsData?.redirectURL ?? ""
        goNews(newsURL: newsMainPageURL)
    }
    
    @IBAction func showMenu(_ sender: Any) {
        self.navigationDrawerController?.openLeftView(velocity: 1.0)
    }
    
    @IBAction func connectVPN(_ sender: Any) {
        connectVPN()
    }
    
    @IBAction func hideBottomBarButtonPress(_ sender: Any ) {
        self.clickMore()
    }
    
    @objc func clickConnect(tapGestureRecognizer: UITapGestureRecognizer) {
        connectVPN()
    }
  
  
    
    @objc func updateVpnStatus() {
        vpnStatus = vpnManager.connection.status
        self.showStatus(status: vpnStatus)
    }
    
    func showStatus(status: NEVPNStatus) {
        self.view.backgroundColor = status ==  .connected ? UIColor.white : AppColors.appCreamColor
        self.btMenu.setImage(UIImage(named: status ==  .connected ? AssetImagesString.menuBlue : AssetImagesString.menuBlack), for: .normal)
        self.newsTable.isHidden = status ==  .connected ? false : true
        self.btNews.isHidden = status ==  .connected ? false : true
        self.logoImageStackView.isHidden = status ==  .connected ? true : false

        // Show/hide slider and connection quality label based on connection status
        self.sliderView.isHidden = status != .connected
        self.connectionQualityLabel.isHidden = status != .connected

        btConnect.setTitleColor((status ==  .connecting || status == .disconnecting) ? .white.withAlphaComponent(0.6) : UIColor.white, for: .normal)
        btConnect.layer.borderColor = (status ==  .connecting || status == .disconnecting) ? UIColor.white.withAlphaComponent(0.6).cgColor : UIColor.white.cgColor
        btConnect.isEnabled = (status ==  .connecting || status == .disconnecting) ? false : true
        if status ==  .connected {
            // When connected, use closed height (but opened height is now 194)
            self.heightConnectButtonView.constant = closedConnectButtonViewHeight
            self.cleanWebViewCookiesAndReloadTable()
            btConnect.setTitle(LocalizedStringEnum.Disconnect.localized, for: .normal)
            if !isNewsCalled {
                if newsData == nil {
                    if let tempNewsData = APIDataCacher.sharedInstance.getCacheData(forKey: .News) {
                        self.newsData = tempNewsData as? NewsData
                        self.cleanWebViewCookiesAndReloadTable()
                    }
                }
                isShowBottomView = false
                let newsMainPageURL = newsData?.redirectURL ?? ""
                goNews(newsURL: newsMainPageURL)
            }
            isNewsCalled = true

            // Start connectivity monitoring when VPN is connected
            startConnectivityMonitoring()
        } else {
            // When disconnected, set to disconnected height (136)
            // Only update if view is currently open (not in closed 40px state)
            if self.heightConnectButtonView.constant > closedConnectButtonViewHeight {
                self.heightConnectButtonView.constant = openedConnectButtonViewHeight
                self.view.layoutIfNeeded()
            }

            btConnect.setTitle(LocalizedStringEnum.Connect.localized, for: .normal)
            btNews.isHidden = true
            isNewsCalled = false
            newsOverlayView.isHidden = true
//            ImageCacher.shared.clearCache()

            // Stop connectivity monitoring when VPN is not connected
            stopConnectivityMonitoring()
        }
        if status ==  .connecting {
            btConnect.setTitle(LocalizedStringEnum.Connecting.localized, for: .normal)
            // When connecting, prepare for connected state (height will be 194 when expanded)
            if self.heightConnectButtonView.constant > closedConnectButtonViewHeight {
                self.heightConnectButtonView.constant = openedConnectButtonViewHeight
                self.view.layoutIfNeeded()
            }
        } else if vpnStatus == .disconnecting   {
            btConnect.setTitle(LocalizedStringEnum.Disconnecting.localized, for: .normal)
            staticValueIndicatorView.isHidden = true
            // When disconnecting, prepare for disconnected state (height will be 136 when expanded)
            if self.heightConnectButtonView.constant > closedConnectButtonViewHeight {
                self.heightConnectButtonView.constant = openedConnectButtonViewHeight
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    private func setupInitialData() {
        self.setupNibs()
        btConnect.layer.borderColor = UIColor.white.cgColor
        btConnect.setTitleColor(UIColor.white, for: .normal)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickConnect(tapGestureRecognizer:)))
        ivConnect.isUserInteractionEnabled = true
        ivConnect.addGestureRecognizer(tapGestureRecognizer)
        self.setupConnectButtonViewGestures()
        self.setupLocalNotifications()
        self.setupEmojiSlider()
    }
    
    private func setupNibs(){
        self.newsTable.register(UINib(nibName: HomeNotificationTableViewCell.className, bundle: nil), forCellReuseIdentifier: HomeNotificationTableViewCell.className)
        self.newsTable.register(UINib(nibName: NewsBottomListTableViewCell.className, bundle: nil), forCellReuseIdentifier: NewsBottomListTableViewCell.className)
        self.newsTable.register(UINib(nibName: NewsTopHeadingTableViewCell.className, bundle: nil), forCellReuseIdentifier: NewsTopHeadingTableViewCell.className)

    }
    
    private func setupLocalNotifications(){
        let foregroundNotification = NotificationCenter.default
        foregroundNotification.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func setupConnectButtonViewGestures(){
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(showConnectButton))
        swipeUpGesture.direction = .up
        connectButtonView.addGestureRecognizer(swipeUpGesture)
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(showConnectButton))
        swipeDownGesture.direction = .down
        connectButtonView.addGestureRecognizer(swipeDownGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickMore))
        viewBottomTap.isUserInteractionEnabled = true
        viewBottomTap.addGestureRecognizer(tapGesture)
    }

    private func setupEmojiSlider() {
        // Create and configure emoji slider
        let slider = EmojiSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isInteractionEnabled = false // Disable user interaction
        slider.currentStep = 2 // Start at Normal (middle)

        // Add to sliderView
        sliderView.addSubview(slider)

        // Setup constraints
        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: sliderView.topAnchor),
            slider.leadingAnchor.constraint(equalTo: sliderView.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: sliderView.trailingAnchor),
            slider.bottomAnchor.constraint(equalTo: sliderView.bottomAnchor)
        ])

        self.emojiSlider = slider

        // Initially hide slider and label (will show when VPN connects)
        sliderView.isHidden = true
        connectionQualityLabel.isHidden = true
    }
    
    @objc func clickMore() {
        if vpnStatus != .connected {
            return
        }
        if isShowBottomView {
            UIView.animate(withDuration: 0.4, animations: {
                self.heightConnectButtonView.constant = self.closedConnectButtonViewHeight
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.heightConnectButtonView.constant = self.openedConnectButtonViewHeight
                self.view.layoutIfNeeded()
            })
        }
        isShowBottomView = !isShowBottomView
    }
    
    @objc func showConnectButton(gesture: UIGestureRecognizer) {
        if vpnStatus != .connected {
            return
        }
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .down:
                UIView.animate(withDuration: 0.4, animations: { [self] in
                    self.heightConnectButtonView.constant = self.closedConnectButtonViewHeight
                    self.cleanWebViewCookiesAndReloadTable()
                    self.view.layoutIfNeeded()
                })
                isShowBottomView = false
                break
            case .up:
                UIView.animate(withDuration: 0.4, animations: {
                    self.heightConnectButtonView.constant = self.openedConnectButtonViewHeight
                    self.view.layoutIfNeeded()
                })
                isShowBottomView = true
                break
            default:
                break
            }
        }
    }


    @objc func appCameToForeground() {
        if (vpnStatus == .connected) {
            self.heightConnectButtonView.constant = closedConnectButtonViewHeight
            isShowBottomView = false
            self.view.layoutIfNeeded()
            reloadTopNews()
            return
        }
        UIView.animate(withDuration: 0.4, animations: {
            self.heightConnectButtonView.constant = self.openedConnectButtonViewHeight
            self.view.layoutIfNeeded()
        })
        isShowBottomView = true
    }
    
    private func reloadTopNews() {
        if (newsData?.headlineNews?.count ?? 0) <= 3 {
            return
        }
        let totalHeadlineCount = newsData?.headlineNews?.count ?? 0
        let topNewsCount = min(4, totalHeadlineCount)
        let pinnedNews = newsData?.headlineNews?.filter { $0.pinToTop == true } ?? []
        let nonPinnedNews = newsData?.headlineNews?.filter { $0.pinToTop != true } ?? []
        
        var topHeadlineNews = [HeadlineNewsData]()
        
        if !pinnedNews.isEmpty {
            if pinnedNews.count >= topNewsCount {
                topHeadlineNews.append(contentsOf: Array(pinnedNews.prefix(topNewsCount)))
            } else {
                topHeadlineNews.append(contentsOf: pinnedNews)
                let remainingCount = topNewsCount - pinnedNews.count
                if remainingCount > 0 && nonPinnedNews.count >= remainingCount {
                    if let randomIndices = generateUniqueRandomNumbers(count: remainingCount, min: 0, max: nonPinnedNews.count - 1, customNumber: nil) {
                        for index in randomIndices {
                            topHeadlineNews.append(nonPinnedNews[index])
                        }
                    }
                } else if remainingCount > 0 {
                    topHeadlineNews.append(contentsOf: nonPinnedNews)
                }
            }
        } else {
            if let randomIndices = generateUniqueRandomNumbers(count: topNewsCount, min: 0, max: totalHeadlineCount - 1, customNumber: nil) {
                for index in randomIndices {
                    if let newsItem = newsData?.headlineNews?[index] {
                        topHeadlineNews.append(newsItem)
                    }
                }
            }
        }
        
        newsData?.topHeadlineNews.removeAll()
        for item in topHeadlineNews {
            newsData?.topHeadlineNews.append(item)
        }

        self.cleanWebViewCookiesAndReloadTable()
    }

    
    private func cleanWebViewCookiesAndReloadTable() {
        clearWKWebViewCookies {
            DispatchQueue.main.async {
                self.newsTable.reloadData()
            }
        }
    }
    
    func clearWKWebViewCookies(completion: @escaping () -> Void) {
        let dataTypes = Set([WKWebsiteDataTypeCookies])
        let dateFrom = Date(timeIntervalSince1970: 0)
        
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: dateFrom) {
            print("WKWebView cookies cleared.")
            completion()
        }
    }
   
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.newsData?.notifications?.count ?? 0
        case 1:
            return self.newsData?.topHeadlineNews.count ?? 0
        case 2:
            return self.newsData?.headlineNews?.count ?? 0
        default:
          return  0
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{
            return  UIDevice.current.userInterfaceIdiom == .pad ? 220 : 180
        } else  if indexPath.section == 2 {
            return 70
        }
        return UITableView.automaticDimension

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if(indexPath.row > (newsData?.notifications?.count ?? 0)-1){
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeNotificationTableViewCell.className, for: indexPath) as? HomeNotificationTableViewCell
            let tempData = newsData?.notifications?[indexPath.row]
            cell?.setupData(data: tempData)
            return cell!
        case 1:
            if(indexPath.row > (newsData?.topHeadlineNews.count ?? 0)-1){
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsTopHeadingTableViewCell.className, for: indexPath) as? NewsTopHeadingTableViewCell
            let tempData = newsData?.topHeadlineNews[indexPath.row]
            cell?.delegate = self
            cell?.setupData(data: tempData)
            return cell!
        case 2:
            if(indexPath.row > (newsData?.headlineNews?.count ?? 0)-1){
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsBottomListTableViewCell.className, for: indexPath) as? NewsBottomListTableViewCell
            let tempData = newsData?.headlineNews?[indexPath.row]
            cell?.setupData(data: tempData, index: indexPath.row)
            return cell!
        default:
            return  UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let tempData = newsData?.notifications?[indexPath.row].url ?? ""
            goNews(newsURL: tempData)
        case 1:
            let tempData = newsData?.topHeadlineNews[indexPath.row].url ?? ""
            goNews(newsURL: tempData)
        case 2:
            let tempData = newsData?.headlineNews?[indexPath.row].url ?? ""
            goNews(newsURL: tempData)
        default:
          return
        }
    }
    
    func goNews(newsURL:String) {
        if VPNServiceManager.sharedInstance.isVPNConnectedViaDiagnostics {return}
        let newViewController = UIStoryboard.loadNewsController()
        newViewController.newsURL = newsURL
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
}




extension HomeViewController : NewsTopHeadingTableViewCellDelegate {
    func newsTopHeadingTableViewCell(_ newsTopHeadingTableViewCell:NewsTopHeadingTableViewCell, didClickOpenNewsWith url:String, type: ReportEventType) {
        goNews(newsURL: url)
    }

}

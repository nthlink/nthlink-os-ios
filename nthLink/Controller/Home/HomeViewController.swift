//
//  HomeViewController.swift
//  nthLink
//
//  Created by Vaneet Modgill on 13/02/24.
//

import UIKit
import NetworkExtension

class HomeViewController: AppBaseViewController {
    @IBOutlet weak var btNews: UIButton!
    @IBOutlet weak var btMenu: UIButton!
    @IBOutlet weak var ivConnect: UIImageView!
    @IBOutlet weak var homeBtView: UIView!
    @IBOutlet weak var btConnect: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var newsTable: UITableView!
    @IBOutlet weak var viewBottomTap: UIImageView!
    @IBOutlet weak var newView: UIView!
    @IBOutlet weak var heightNewsView: NSLayoutConstraint!
    
    private var vpnStatus:NEVPNStatus = .disconnected
    var isNewsCalled = false
    var isShowNews = false
    var newsData:NewsData?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialData()
        self.updateVpnStatus()
        self.createVPNConfiguration()
        self.getServerConfig()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if (vpnStatus == .connected) && isFromFeedback {
            isFromFeedback = false
                self.heightNewsView.constant = self.view.frame.height - 80
                self.view.layoutIfNeeded()
            isShowNews = true
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    
   deinit {
       NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: vpnManager.connection)
   }
    
    @IBAction func goNewsPage(_ sender: Any ) {
        let newsMainPageURL = newsData?.redirectURL ?? ""
        goNews(newsURL: newsMainPageURL)
    }
    
    @IBAction func showMenu(_ sender: Any) {
        self.navigationDrawerController?.openLeftView(velocity: 1.0)
    }
    
    @IBAction func goLandingPage(_ sender: Any) {
        let newsMainPageURL = newsData?.redirectURL ?? ""
        goNews(newsURL: newsMainPageURL)
    }
    
    @IBAction func connectVPN(_ sender: Any) {
        connectVPN()
    }
    
    @objc func clickConnect(tapGestureRecognizer: UITapGestureRecognizer) {
        connectVPN()
    }
  
    
    @objc func updateVpnStatus() {
        vpnStatus = vpnManager.connection.status
        self.showStatus(status: vpnStatus)
    }
    
    func showStatus(status: NEVPNStatus) {
        self.ivConnect.image = UIImage(named: status ==  .connected ? AssetImagesString.appLogoWhite : AssetImagesString.appLogoBlue)
        self.view.backgroundColor = status ==  .connected ? AppColors.appBlueColor : AppColors.appCreamColor
        self.lbTitle.textColor = status ==  .connected ? .white : .black
        self.btMenu.setImage(UIImage(named: status ==  .connected ? AssetImagesString.menuWhite : AssetImagesString.menuBlack), for: .normal)
        self.newView.isHidden = status ==  .connected ? false : true
        self.btNews.isHidden = status ==  .connected ? false : true
        self.homeBtView.isHidden = status ==  .connected ? false : true
        btConnect.setTitleColor(status ==  .connected ? .white : AppColors.appBlueColor, for: .normal)
        btConnect.layer.borderColor = status ==  .connected ? UIColor.white.cgColor : AppColors.appBlueColor.cgColor
        if status ==  .connected {
            self.heightNewsView.constant = self.view.frame.height - 80
            newsTable.reloadData()
            btConnect.setTitle(LocalizedStringEnum.Disconnect.localized, for: .normal)
            if !isNewsCalled {
                if newsData == nil {
                    if let tempNewsData = APIDataCacher.sharedInstance.getCacheData(forKey: .News) {
                        self.newsData = tempNewsData as? NewsData
                        self.newsTable.reloadData()
                    }
                }
                isShowNews = true
                let newsMainPageURL = newsData?.redirectURL ?? ""
                goNews(newsURL: newsMainPageURL) //TODO:
            }
            isNewsCalled = true
            
        } else {
            btConnect.setTitle(LocalizedStringEnum.Connect.localized, for: .normal)
            btNews.isHidden = true
            isNewsCalled = false
        }
        if status ==  .connecting {
            btConnect.setTitle(LocalizedStringEnum.Connecting.localized, for: .normal)
        } else if vpnStatus == .disconnecting   {
            btConnect.setTitle(LocalizedStringEnum.Disconnecting.localized, for: .normal)
        }
    }
    
    
    private func setupInitialData() {
        self.setupNibs()
        btConnect.layer.borderColor = AppColors.appBlueColor.cgColor
        btConnect.setTitleColor(AppColors.appBlueColor, for: .normal)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickConnect(tapGestureRecognizer:)))
        ivConnect.isUserInteractionEnabled = true
        ivConnect.addGestureRecognizer(tapGestureRecognizer)
        self.setupNewsViewGestures()
        self.setupLocalNotifications()
    }
    
    private func setupNibs(){
        self.newsTable.register(UINib(nibName: HomeNotificationTableViewCell.className, bundle: nil), forCellReuseIdentifier: HomeNotificationTableViewCell.className)
        self.newsTable.register(UINib(nibName: NewsBottomListTableViewCell.className, bundle: nil), forCellReuseIdentifier: NewsBottomListTableViewCell.className)

    }
    
    private func setupLocalNotifications(){
        let foregroundNotification = NotificationCenter.default
        foregroundNotification.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func setupNewsViewGestures(){
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(showNews))
        swipeUpGesture.direction = .up
        newView.addGestureRecognizer(swipeUpGesture)
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(showNews))
        swipeDownGesture.direction = .down
        newView.addGestureRecognizer(swipeDownGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickMore))
        viewBottomTap.isUserInteractionEnabled = true
        viewBottomTap.addGestureRecognizer(tapGesture)
    }
    
    @objc func clickMore() {
        if isShowNews {
            UIView.animate(withDuration: 0.4, animations: {
                self.heightNewsView.constant = 80
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.heightNewsView.constant = self.view.frame.height - 80
                self.view.layoutIfNeeded()
            })
        }
        isShowNews = !isShowNews
    }
    
    @objc func showNews(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .down:
                UIView.animate(withDuration: 0.4, animations: { [self] in
                    self.heightNewsView.constant = 80
                    newsTable.reloadData()
                    self.view.layoutIfNeeded()
                })
                isShowNews = false
                break
            case .up:
                UIView.animate(withDuration: 0.4, animations: {
                    self.heightNewsView.constant = self.view.frame.height - 80
                    self.view.layoutIfNeeded()
                })
                isShowNews = true
                break
            default:
                break
            }
        }
    }


    @objc func appCameToForeground() {
        if (vpnStatus == .connected) {
            self.heightNewsView.constant = self.view.frame.height - 80
            self.view.layoutIfNeeded()
            newsTable.reloadData()
        }
    }
   
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.newsData?.notifications?.count ?? 0
        case 1:
            return self.newsData?.headlineNews?.count ?? 0
        default:
          return  0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeNotificationTableViewCell.className, for: indexPath) as? HomeNotificationTableViewCell
            let tempData = newsData?.notifications?[indexPath.row]
            cell?.setupData(data: tempData)
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsBottomListTableViewCell.className, for: indexPath) as? NewsBottomListTableViewCell
            let tempData = newsData?.headlineNews?[indexPath.row]
            cell?.setupData(data: tempData, index: indexPath.row)
            return cell!
        default:
          return  UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       if indexPath.section == 1 {
            return 70
        }
        return UITableView.automaticDimension

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let tempData = newsData?.notifications?[indexPath.row].url ?? ""
            goNews(newsURL: tempData)
        case 1:
            let tempData = newsData?.headlineNews?[indexPath.row].url ?? ""
            goNews(newsURL: tempData)
        default:
          return
        }
    }
    
    func goNews(newsURL:String) {
        let newViewController = UIStoryboard.loadNewsController()
        newViewController.newsURL = newsURL
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
}

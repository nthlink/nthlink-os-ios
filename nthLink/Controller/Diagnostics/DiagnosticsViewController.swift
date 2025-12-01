//
//  DiagnosticsViewController.swift
//  nthLink
//
//  Created by Vaneet Modgill on 03/12/24.
//

import UIKit
import SwiftyJSON
import Network
import CoreTelephony

class DiagnosticsViewController: AppBaseViewController {
    let progressHUD = ProgressHUD(text: LocalizedStringEnum.loading.localized)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = VPNServiceManager.sharedInstance.isReachable
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        VPNServiceManager.sharedInstance.isVPNConnectedViaDiagnostics = false
    }
    
    @IBAction func startDiagnosticsButtonPressed(_ sender: Any) {
        if !VPNServiceManager.sharedInstance.isReachable {
            self.showCommonAlert(title:  LocalizedStringEnum.Notice.localized, message:  LocalizedStringEnum.diagnosticsInternetError.localized, controller: self)
            return
        }
        if vpnManager.connection.status == .connected {
            let alert = UIAlertController(title: "", message: LocalizedStringEnum.diagnosticsStartDisconnectWarning.localized, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: LocalizedStringEnum.Cancel.localized, style: UIAlertAction.Style.default, handler: nil))
            alert.addAction(UIAlertAction(title: LocalizedStringEnum.OK.localized, style: UIAlertAction.Style.default, handler: {_ in
                self.showActivityLoader()
                vpnManager.connection.stopVPNTunnel()
                DispatchQueue.main.asyncAfter(deadline: .now()+3.0, execute: {
                    self.sendDiagnostics()
                })
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.showActivityLoader()
        self.sendDiagnostics()
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func getCarrierName() -> String {
        let networkInfo = CTTelephonyNetworkInfo()
        if let carrier = networkInfo.serviceSubscriberCellularProviders?.values.first {
            return carrier.carrierName ?? ""
        }
        return ""
    }
     
    func getNetworkType() -> String {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        var networkType = "OTHER"
        monitor.pathUpdateHandler = { path in
            if path.usesInterfaceType(.wifi) {
                networkType = "WIFI"
            } else if path.usesInterfaceType(.cellular) {
                networkType = "CELLULAR"
            } else {
                networkType = "OTHER"
            }
        }
        monitor.start(queue: queue)
        Thread.sleep(forTimeInterval: 1.0)
        monitor.cancel()
        return networkType
    }
    
    private func showActivityLoader() {
        self.view.addSubview(progressHUD)
        
    }
    
    private func hideActivityLoader() {
        self.progressHUD.removeFromSuperview()
    }

    func sendDiagnostics() {
        // Hardcoded success response (nthLinkOpenSource approach)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hideActivityLoader()
            self.showCommonAlert(title: LocalizedStringEnum.Notice.localized, message: LocalizedStringEnum.diagnosticsSuceessMessage.localized, controller: self)
        }
    }

}

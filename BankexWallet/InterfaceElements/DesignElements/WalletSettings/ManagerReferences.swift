//
//  ManagerReferences.swift
//  BankexWallet
//
//  Created by Vladislav on 21.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI
import Reachability
import CoreTelephony




class ManagerReferences {
    
    enum references {
        case twitter,telegram,facebook,bankex,appStore
        func getRef() -> String {
            switch self {
            case .facebook: return "https://www.facebook.com/BankExchange/"
            case .telegram: return "https://t.me/bankexpay"
            case .twitter: return "https://twitter.com/BANKEX"
            case .appStore: return "itms-apps://itunes.apple.com/app/id1411403963"
            case .bankex: return "a.ingachev@bankex.com"
            }
        }
    }
    
    func accessToBankexMail(delegate:MFMailComposeViewControllerDelegate?, failed:@escaping ((String)->()),success:@escaping ((MFMailComposeViewController)->())) {
        var errorMessage = ""
        guard MFMailComposeViewController.canSendMail() else {
            errorMessage += "Device is not available to send email.Please check your settings"
            failed(errorMessage)
            return
        }
        let mc = MFMailComposeViewController()
        mc.mailComposeDelegate = delegate
        mc.setToRecipients([references.bankex.getRef()])
        mc.setSubject("TO BANKEX")
        var messageBody = "When I do the following:\n1. \n2. \n3. \n\nThe app does:\n\nBut it should do:\n\n"
        let padding = "--------------------"
        messageBody += "\(padding)\nWith details listed below we will find solutions faster. Please do not remove this text.\n\(padding)\n"
        let device = UIDevice.current
        messageBody += "Operating system: \(device.systemName) \(device.systemVersion)\n"
        messageBody += "Device: Apple \(UIDevice.modelName)\n"
        if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String, let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            messageBody += "Application: \(appName) \(version)\n"
        }
        messageBody += "Connection Type: \(getNetworkType())\n"
        if let language = Locale.current.languageCode {
            messageBody += "Language Code: \(language)\n"
        }
        if let country = Locale.current.regionCode {
            messageBody += "Country Code: \(country)"
        }
        mc.setMessageBody(messageBody, isHTML: false)
        DispatchQueue.main.async {
            success(mc)
        }
    }
    
    
    
    func accessToTwitter() {
        guard UIApplication.shared.canOpenURL(URL(string:references.twitter.getRef())!) else {
            //Show error
            return
        }
        if #available(iOS 10.0,*) {
            UIApplication.shared.open(URL(string: references.twitter.getRef())!, options: [:], completionHandler: nil)
        }else {
            UIApplication.shared.openURL(URL(string:references.twitter.getRef())!)
        }
    }
    
    func accessToTelegram() {
        guard UIApplication.shared.canOpenURL(URL(string:references.telegram.getRef())!) else {
            //Show error
            return
        }
        if #available(iOS 10.0,*) {
            UIApplication.shared.open(URL(string: references.telegram.getRef())!, options: [:], completionHandler: nil)
        }else {
            UIApplication.shared.openURL(URL(string:references.telegram.getRef())!)
        }
    }
    
    func accessToFacebook() {
        guard UIApplication.shared.canOpenURL(URL(string:references.facebook.getRef())!) else {
            //Show error
            return
        }
        if #available(iOS 10.0,*) {
            UIApplication.shared.open(URL(string: references.facebook.getRef())!, options: [:], completionHandler: nil)
        }else {
            UIApplication.shared.openURL(URL(string:references.facebook.getRef())!)
        }
    }
    
    func accessToAppStore() {
        DispatchQueue.main.async {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }else {
                self.estimateApp()
            }
        }
    }
    
    fileprivate func estimateApp() {
        guard let url = URL(string:references.appStore.getRef()) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func getNetworkType() -> String {
        let reachability: Reachability = Reachability()!
        do {
            try reachability.startNotifier()
            let status = reachability.connection
            if(status == .none) {
                return "No connection"
            } else if (status == .wifi){
                return "Wifi"
            } else if (status == .cellular) {
                let networkInfo = CTTelephonyNetworkInfo()
                let carrierType = networkInfo.currentRadioAccessTechnology
                switch carrierType {
                case CTRadioAccessTechnologyGPRS?,CTRadioAccessTechnologyEdge?,CTRadioAccessTechnologyCDMA1x?: return "2G"
                case CTRadioAccessTechnologyWCDMA?,CTRadioAccessTechnologyHSDPA?,CTRadioAccessTechnologyHSUPA?,CTRadioAccessTechnologyCDMAEVDORev0?,CTRadioAccessTechnologyCDMAEVDORevA?,CTRadioAccessTechnologyCDMAEVDORevB?,CTRadioAccessTechnologyeHRPD?: return "3G"
                case CTRadioAccessTechnologyLTE?: return "4G"
                default: return ""
                }
            } else {
                return ""
            }
        } catch {
            return ""
        }
        
    }
    
}

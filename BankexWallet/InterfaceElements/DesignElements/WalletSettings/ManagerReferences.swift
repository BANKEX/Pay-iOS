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

class ManagerReferences {
    private enum references {
        case twitter,telegram,facebook,bankex,appStore
        func getRef() -> String {
            switch self {
            case .facebook: return "https://www.facebook.com/BankExchange/"
            case .telegram: return "https://t.me/bankex"
            case .twitter: return "https://twitter.com/BANKEX"
            case .appStore: return "itms-apps://itunes.apple.com/app/BANKEX-Pay/id1411403963"  //Change later
            case .bankex: return "wallet@bankexfoundation.org"
            }
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
    
    func writeToUs() {
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.setToRecipients([references.bankex.getRef()])
        }else {
            //Show error later
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
    
}

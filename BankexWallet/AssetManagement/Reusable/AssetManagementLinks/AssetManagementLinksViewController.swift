//
//  AssetManagementLinksViewController.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 29/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import MessageUI

class AssetManagementLinksViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @IBAction func sendEmail() {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setToRecipients(["support@bankex.com"])
        mailComposeViewController.setSubject("")
        mailComposeViewController.setMessageBody("", isHTML: false)
        
        present(mailComposeViewController, animated: true, completion: nil)
    }
    
    @IBAction func openTelegram() {
        let channelURL = URL.init(string: "tg://resolve?domain=bankex")!
        
        UIApplication.shared.openURL(channelURL)
    }
    
    @IBAction func openPage() {
        let pageURL = URL(string: "https://bankex.com/en/sto/asset-management")!
        
        UIApplication.shared.openURL(pageURL)
    }
    
}

extension AssetManagementLinksViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}


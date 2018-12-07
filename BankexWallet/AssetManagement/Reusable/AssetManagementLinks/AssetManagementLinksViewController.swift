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
        let mailComposeViewController: MFMailComposeViewController? = MFMailComposeViewController()
        
        guard let viewController = mailComposeViewController else { return }
        
        viewController.mailComposeDelegate = self
        viewController.setSubject("")
        viewController.setMessageBody("", isHTML: false)
        viewController.setToRecipients(["sales@bankex.com"])
        
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func openTelegram() {
        let channelURL = URL.init(string: "tg://resolve?domain=bankexpay")!
        
        UIApplication.shared.openURL(channelURL)
    }
    
    @IBAction func openPage() {
        performSegue(withIdentifier: "Browser", sender: self)
    }
}

extension AssetManagementLinksViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let browser = segue.destination as? AssetManagementBrowserViewController {
            browser.link = URL(string: "https://bankex.com/en/sto/asset-management")!
        }
    }
}

extension AssetManagementLinksViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}


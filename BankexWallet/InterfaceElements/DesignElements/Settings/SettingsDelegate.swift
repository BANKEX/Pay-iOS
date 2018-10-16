//
//  UITableViewDelegate.swift
//  BankexWallet
//
//  Created by Vladislav on 21.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import MessageUI


extension SettingsViewController:MFMailComposeViewControllerDelegate {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedSection = indexPath.section
        switch indexPath.section {
        case SettingsSections.General.rawValue:
            if indexPath.row == 0 {
                performSegue(withIdentifier: "networkSegue", sender: self)
            }else if indexPath.row == 1 {
                performSegue(withIdentifier: "walletSegue", sender: self)
            }else {
                performSegue(withIdentifier: "securitySegue", sender: self)
            }
        case SettingsSections.Support.rawValue:
            if indexPath.row == 0 {
                managerReferences.accessToBankexMail(delegate: self, failed: { (errorMessage) in
                    DispatchQueue.main.async {
                        let alertVC = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: errorMessage, preferredStyle: .alert)
                        alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default))
                        self.present(alertVC, animated: true)
                    }
                }) { (composeViewController) in
                    self.present(composeViewController, animated: true)
                }
            }else {
                managerReferences.accessToAppStore()
            }
        case SettingsSections.Community.rawValue:
            if indexPath.row == 0 {
                performSegue(withIdentifier: "products", sender: nil)
            }else if indexPath.row == 1 {
                managerReferences.accessToTwitter()
            }else if indexPath.row == 2 {
                managerReferences.accessToFacebook()
            }else {
                managerReferences.accessToTelegram()
            }
        case SettingsSections.Developer.rawValue:
            self.performSegue(withIdentifier: "dev", sender: nil)
            //self.performSegue(withIdentifier: "networkSegue", sender: nil)
        default: break
        }
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

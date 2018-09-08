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
        switch indexPath.section {
        case SettingsSections.Main.rawValue:
            if indexPath.row == 0 {
                performSegue(withIdentifier: "networkSegue", sender: self)
            }else if indexPath.row == 1 {
                performSegue(withIdentifier: "walletSegue", sender: self)
            }else {
                performSegue(withIdentifier: "securitySegue", sender: self)
            }
        case SettingsSections.AppStore.rawValue:
            if indexPath.row == 0 {
                managerReferences.accessToBankexMail(delegate: self, failed: { (errorMessage) in
                    DispatchQueue.main.async {
                        let alertVC = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                        alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default))
                        self.present(alertVC, animated: true)
                    }
                }) { (composeViewController) in
                    self.present(composeViewController, animated: true)
                }
            }else {
                managerReferences.accessToAppStore()
            }
        case SettingsSections.SocialNetwork.rawValue:
            if indexPath.row == 0 {
                managerReferences.accessToTwitter()
            }else if indexPath.row == 1 {
                managerReferences.accessToFacebook()
            }else {
                managerReferences.accessToTelegram()
            }
        default: break
        }
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

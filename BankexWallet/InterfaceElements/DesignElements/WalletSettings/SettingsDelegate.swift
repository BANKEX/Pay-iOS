//
//  UITableViewDelegate.swift
//  BankexWallet
//
//  Created by Vladislav on 21.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

extension SettingsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                performSegue(withIdentifier: "networkSegue", sender: self)
            }else if indexPath.row == 1 {
                //Wallets
            }else {
                //security
            }
        case 1:
            if indexPath.row == 0 {
                managerReferences.writeToUs()
            }else {
                managerReferences.accessToAppStore()
            }
        case 2:
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
}

//
//  WalletInfoViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 17/08/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class WalletInfoViewController: UITableViewController {
    
    var publicAddress: String?
    let walletsService: GlobalWalletsService = HDWalletServiceImplementation()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            //TODO: - there are no such segues yes
            case 0:
                self.performSegue(withIdentifier: "toPassphrase", sender: nil)
            case 1:
                self.performSegue(withIdentifier: "toPrivateKey", sender: nil)
            default:
                print("Unreal")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

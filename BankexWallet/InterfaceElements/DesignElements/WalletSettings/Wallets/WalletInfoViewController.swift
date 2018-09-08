//
//  WalletInfoViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 17/08/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class WalletInfoViewController: UITableViewController {
    @IBOutlet weak var addressLabel: UILabel!
    
    var publicAddress: String?
    let walletsService: GlobalWalletsService = HDWalletServiceImplementation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = publicAddress
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "ShowPassphrase", sender: nil)
            case 1:
                self.performSegue(withIdentifier: "ShowPrivateKey", sender: nil)
            default:
                print("Unreal")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AttentionViewController {
            vc.publicAddress = publicAddress
        } else if let vc = segue.destination as? BackupPassphraseViewController {
            vc.navTitle = "Backup Phrase"
        }
    }
}

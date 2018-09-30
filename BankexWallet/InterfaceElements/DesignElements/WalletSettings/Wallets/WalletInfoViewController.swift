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
    @IBOutlet weak var nameWalletLabel:UILabel!
    var dict:[String:String]!
    var publicAddress:String?
    let walletsService: GlobalWalletsService = HDWalletServiceImplementation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = dict["addr"]
        nameWalletLabel.text = dict["name"]
        publicAddress = dict["addr"]
        title = "Wallet Info"
        tableView.backgroundColor = WalletColors.bgMainColor
        tableView.tableFooterView = HeaderView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "ShowPassphrase", sender: nil)
            case 1:
                self.performSegue(withIdentifier: "ShowPrivateKey", sender: nil)
            case 2:
                self.performSegue(withIdentifier: "renameSegue", sender: nil)
            case 3:
                //Delete
                if isSimilarWallet() {
                    let alertVC = UIAlertController(title: "Error", message: "You can't to delete selected wallet", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alertVC, animated: true)
                    return
                }
                let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alertViewController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    if let addr = self.addressLabel.text {
                        self.walletsService.delete(address: addr)
                        self.navigationController?.popViewController(animated: true)
                    }
                }))
                alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alertViewController, animated: true)
            default:
                print("Unreal")
            }
        }
    }
    
    
    func isSimilarWallet() -> Bool {
        if let addr = addressLabel.text,let wallet = walletsService.selectedWallet() {
            return addr == wallet.address
        }
        return true
    }
        
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AttentionViewController {
            vc.publicAddress = publicAddress
        } else if let vc = segue.destination as? BackupPassphraseViewController {
            vc.navTitle = "Backup Phrase"
        }else if let renameVC = segue.destination as? RenameViewController {
            if let nameWallet = nameWalletLabel.text {
                renameVC.selectedWalletName = nameWallet
                renameVC.delegate = self
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView()
        if section == 0 {
            headerView.title = "WALLET INFORMATION"
        }else {
            headerView.title = "WALLET SECURITY"
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54.0
    }
}

extension WalletInfoViewController:RenameViewControllerDelegate {
    func didUpdateWalletName(name: String) {
        nameWalletLabel.text = name
        tableView.reloadData()
    }
    
    func addressOfWallet() -> String {
        return addressLabel.text ?? ""
    }
}


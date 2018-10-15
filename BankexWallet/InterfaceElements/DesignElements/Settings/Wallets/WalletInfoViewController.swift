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
    var clipboardView:ClipboardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupClipboard()
        addressLabel.text = dict["addr"]
        nameWalletLabel.text = dict["name"]
        publicAddress = dict["addr"]
        title = NSLocalizedString("WalletInfo", comment: "")
        tableView.backgroundColor = WalletColors.bgMainColor
        tableView.tableFooterView = HeaderView()
    }
    
    func setupClipboard() {
        clipboardView = ClipboardView(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 58))
        clipboardView.backgroundColor = WalletColors.clipboardColor
        clipboardView.title = NSLocalizedString("AddrCopied", comment: "")
        view.addSubview(clipboardView)
    }
    func saveDataInBuffer(_ string:String?) {
        UIPasteboard.general.string = string ?? ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            clipboardView.showClipboard()
            saveDataInBuffer(addressLabel.text)
        }else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "ShowPrivateKey", sender: nil)
            case 1:
                self.performSegue(withIdentifier: "renameSegue", sender: nil)
            case 2:
                //Delete
                if isSimilarWallet() {
                    let alertVC = UIAlertController.common(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("CantDel", comment: ""))
                    present(alertVC, animated: true)
                    return
                }
                let alertViewController = UIAlertController.destructive(button: NSLocalizedString("Delete", comment: "")) {
                    if let addr = self.addressLabel.text {
                        self.walletsService.delete(address: addr)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
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
            headerView.title = NSLocalizedString("ChooseWallet", comment: "")
        }else {
            headerView.title = NSLocalizedString("WalletSecurity", comment: "")
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


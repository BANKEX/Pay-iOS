//
//  WalletInfoViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 17/08/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class WalletInfoViewController: BaseViewController {
    

    @IBOutlet weak var tableView:UITableView!
    var dict:[String:String]!
    var publicAddress:String?
    let walletsService: GlobalWalletsService = HDWalletServiceImplementation()
    var clipboardView:ClipboardView!
    let generalCellIdentifier = "GeneralInformationCell"
    let infoCellIdentifier = "InfoCell"
    var publicName:String?
    var secondWidth:CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupClipboard()
        publicAddress = dict["addr"]
        publicName = dict["name"]
        title = NSLocalizedString("WalletInfo", comment: "")
        tableView.backgroundColor = UIColor.bgMainColor
        tableView.tableFooterView = HeaderView()
        tableView.register(UINib(nibName: generalCellIdentifier, bundle: nil), forCellReuseIdentifier: generalCellIdentifier)
        tableView.register(UINib(nibName: infoCellIdentifier, bundle: nil), forCellReuseIdentifier: infoCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset.left = 59
        tableView.separatorColor = UIColor.disableColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setupClipboard() {
        if UIDevice.isIpad {
            secondWidth = view.bounds.width - splitViewController!.primaryColumnWidth
        }
        clipboardView = ClipboardView(frame: CGRect(x: 0, y: view.bounds.height, width: UIDevice.isIpad ? secondWidth! : view.bounds.width, height: 58))
        clipboardView.backgroundColor = UIColor.clipboardColor
        clipboardView.title = NSLocalizedString("AddrCopied", comment: "")
        view.addSubview(clipboardView)
    }
    func saveDataInBuffer(_ string:String?) {
        UIPasteboard.general.string = string ?? ""
    }
    
    
    func isSimilarWallet() -> Bool {
        if let addr = publicAddress,let wallet = walletsService.selectedWallet() {
            return addr == wallet.address
        }
        return true
    }
        
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AttentionViewController {
            vc.publicAddress = publicAddress
        }else if let renameVC = segue.destination as? RenameViewController {
            if let nameWallet = publicName {
                renameVC.selectedWalletName = nameWallet
                renameVC.delegate = self
            }
        }
    }
    
    
}

extension WalletInfoViewController:RenameViewControllerDelegate {
    func didUpdateWalletName(name: String) {
        publicName = name
        tableView.reloadData()
    }
    
    func addressOfWallet() -> String {
        return publicAddress ?? ""
    }
}

extension WalletInfoViewController:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: generalCellIdentifier, for: indexPath) as! GeneralInformationCell
            cell.setData(address: publicAddress ?? "", name: publicName ?? "")
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: infoCellIdentifier, for: indexPath) as! InfoCell
            cell.infoState = InfoState(rawValue: indexPath.row)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 62
        }else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView()
        if section == 0 {
            headerView.title = NSLocalizedString("ChooseWallet", comment: "")
        }else {
            headerView.title = NSLocalizedString("WalletSecurity", comment: "")
        }
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            clipboardView.showClipboard()
            saveDataInBuffer(addressOfWallet())
        }else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "ShowPrivateKey", sender: nil)
            case 1:
                if UIDevice.isIpad {
                    let renameVC = CreateVC(byName: "RenameViewController") as! RenameViewController
                    renameVC.addCancelButtonIfNeed()
                    if let nameWallet = publicName {
                        renameVC.selectedWalletName = nameWallet
                        renameVC.delegate = self
                    }
                    presentPopUp(renameVC, size: CGSize(width: splitViewController!.view.bounds.width/2, height: splitViewController!.view.bounds.height/2))
                }else {
                  self.performSegue(withIdentifier: "renameSegue", sender: nil)
                }
            case 2:
                //Delete
                if isSimilarWallet() {
                    let alertVC = UIAlertController.common(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("CantDel", comment: ""))
                    //alertVC.addPopover(in: view, rect: CGRect(x: 0, y: 0, width: 270, height: 100))
                    present(alertVC, animated: true)
                    return
                }
                let alertViewController:UIAlertController
                if UIDevice.isIpad {
                    alertViewController = UIAlertController.destructiveIpad(title: "Delete Wallet", description: "You are going to delete your wallet. This action can’t be undone.", button: NSLocalizedString("Delete", comment: ""), action: {
                        if let addr = self.publicAddress {
                            self.walletsService.delete(address: addr)
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                    alertViewController.addPopover(in: view, rect: CGRect(x: 0, y: 0, width: 270, height: 140))
                }else {
                    alertViewController = UIAlertController.destructive(button: NSLocalizedString("Delete", comment: "")) {
                        if let addr = self.publicAddress {
                            self.walletsService.delete(address: addr)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                present(alertViewController, animated: true)
            default:
                print("Unreal")
            }
        }
        
    }
}



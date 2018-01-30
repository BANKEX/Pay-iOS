//
//  ViewController.swift
//  BankexWallet
//
//  Created by Alexander Vlasov on 26.01.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class WalletsTableViewController: UITableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Single address keystores"
        case 1:
            return "Hierarchic determinicstic (HD) keystores"
        case 2:
            return "Work with your private key"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            guard let c = BankexWalletKeystores.EthereumKeystoresManager.addresses?.count else {return 1}
            return c + 1
        case 1:
            guard let c = BankexWalletKeystores.BIP32KeystoresManager.addresses?.count else {return 1}
            return c + 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddEthereumKeystoreCell", for: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EthereumKeystoreCell", for: indexPath)
                    as! EthereumKeystoreCell
                guard let c = BankexWalletKeystores.EthereumKeystoresManager.addresses?.count else {fatalError("Invalid number of cells")}
                guard indexPath.row < c else {fatalError("Invalid number of cells")}
                cell.addressLabel.text = BankexWalletKeystores.EthereumKeystoresManager.addresses![indexPath.row].address
                return cell
            }
        case 1:
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddBIP32KeystoreCell", for: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BIP32KeystoreCell", for: indexPath)
                    as! EthereumKeystoreCell
                guard let c = BankexWalletKeystores.EthereumKeystoresManager.addresses?.count else {fatalError("Invalid number of cells")}
                guard indexPath.row < c else {fatalError("Invalid number of cells")}
                cell.addressLabel.text = BankexWalletKeystores.EthereumKeystoresManager.addresses![indexPath.row].address
                return cell
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPrivateKeyCell", for: indexPath)
            return cell
        default:
            fatalError("Invalid number of cells")
//            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        switch indexPath.section {
        case 0:
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                guard let newWallet = try? EthereumKeystoreV3(password: "BANKEXFOUNDATION") else {return}
                guard let wallet = newWallet, wallet.addresses != nil, wallet.addresses?.count == 1 else {return}
                guard let keydata = try? JSONEncoder().encode(wallet.keystoreParams) else {return}
                let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                guard let address = newWallet?.addresses?.first?.address else {return}
                let path = userDir + BankexWalletConstants.KeystoreStoragePath
                let fileManager = FileManager.default
                var isDir : ObjCBool = false
                var exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
                if (!exists && !isDir.boolValue){
                    try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                    exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
                }
                if (!isDir.boolValue) {
                    return
                }
                FileManager.default.createFile(atPath: path + "/" + address + ".json", contents: keydata, attributes: nil)
                self.tableView.reloadData()
                return
            } else {
                let address = BankexWalletKeystores.EthereumKeystoresManager.addresses![indexPath.row]
                guard let keystore = BankexWalletKeystores.EthereumKeystoresManager.walletForAddress(address) else {return}
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "SingleAddressTableViewController") as! SingleAddressTableViewController
                controller.tokens = [EthereumAddress]()
                controller.keystore = keystore
                controller.address = address
                self.navigationController?.pushViewController(controller, animated: true)
                return
            }
        case 1:
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                return
            } else {
                return
            }
        case 2:
            return
        default:
            fatalError("Invalid number of cells")
            //            return UITableViewCell()
        }
    }

}


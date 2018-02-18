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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
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
            let c = BankexWalletKeystores.EthereumKeystoresManager.keystores.count
            return c + 1
        case 1:
            let c = BankexWalletKeystores.BIP32KeystoresManager.bip32keystores.count
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
                let c = BankexWalletKeystores.EthereumKeystoresManager.keystores.count
                guard indexPath.row < c else {fatalError("Invalid number of cells")}
                cell.addressLabel.text = BankexWalletKeystores.EthereumKeystoresManager.keystores[indexPath.row].addresses?[0].address
                return cell
            }
        case 1:
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddBIP32KeystoreCell", for: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BIP32KeystoreCell", for: indexPath)
                    as! EthereumKeystoreCell
                let c = BankexWalletKeystores.BIP32KeystoresManager.bip32keystores.count
                guard indexPath.row < c else {fatalError("Invalid number of cells")}
                cell.addressLabel.text = BankexWalletKeystores.BIP32KeystoresManager.bip32keystores[indexPath.row].addresses?[0].address
                return cell
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPrivateKeyCell", for: indexPath)
            return cell
        default:
            fatalError("Invalid number of cells")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        switch indexPath.section {
        case 0:
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                return
            } else {
                let keystore = BankexWalletKeystores.EthereumKeystoresManager.keystores[indexPath.row] as AbstractKeystore
                guard let address = keystore.addresses?[0] else {return}
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
//                let keystore = BankexWalletKeystores.BIP32KeystoresManager.bip32keystores[indexPath.row]
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let controller = storyboard.instantiateViewController(withIdentifier: "HDWalletTableViewController") as! HDWalletTableViewController
//                controller.keystore = keystore
//                self.navigationController?.pushViewController(controller, animated: true)
//                return
            }
        case 2:
            return
        default:
            fatalError("Invalid number of cells")
            //            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            switch indexPath.section{
            case 0:
                if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                    return
                }
                let keystore = BankexWalletKeystores.EthereumKeystoresManager.keystores[indexPath.row]
                let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let address = keystore.addresses![0].address
                let path = userDir + BankexWalletConstants.KeystoreStoragePath
                let fileManager = FileManager.default
                _ = try? fileManager.removeItem(atPath: path + "/" + address + ".json")
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            case 1:
                return
            default:
                return
            }
        default:
            return
        }
    }

}


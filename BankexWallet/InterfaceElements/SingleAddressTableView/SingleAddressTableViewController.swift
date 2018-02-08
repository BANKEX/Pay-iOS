//
//  SingleAddressTableViewController.swift
//  BankexWallet
//
//  Created by Alexander Vlasov on 29.01.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import web3swift
import BigInt

class SingleAddressTableViewController: UITableViewController {
    
    var tokens: [EthereumAddress] = [EthereumAddress]()
    var address: EthereumAddress? = nil
    var keystore: AbstractKeystore? = nil

//    convenience init(tokens: [EthereumAddress], keystore: AbstractKeystore, address: EthereumAddress?) {
//        self.init()
//        self.tokens = tokens
//        self.keystore = keystore
//        if (address == nil) {
//            self.address = keystore.addresses?.first
//        } else {
//            assert(keystore.addresses?.first == address)
//            self.address = address
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if (self.address != nil) {
//            self.navigationItem.title = self.address?.address
//            self.navigationController?.navigationBar.titleTextAttributes = [
//                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10)]
//        }
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
            return "Address"
        case 1:
            return "Balance"
        case 2:
            return "Token balances"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return self.tokens.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath)
                as! AddressCell
            cell.addressLabel.text = self.address?.address
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceCell", for: indexPath)
                as! BalanceCell
            let balance = BankexWalletWeb3.web3.eth.getBalance(address: self.address!, onBlock: "pending")
            if (balance == nil) {
                return cell
            }
            guard let formattedAmount = Web3.Utils.formatToEthereumUnits(balance!, toUnits: .eth, decimals: 3) else {return cell}
            cell.balanceLabel.text = formattedAmount + " ETH"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TokenBalanceCell", for: indexPath)
                as! TokenBalanceCell
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
//        switch indexPath.section {
//        case 0:
//            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
//                return
//            } else {
//                return
//            }
//        case 1:
//            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
//                return
//            } else {
//                return
//            }
//        case 2:
//            return
//        default:
//            fatalError("Invalid number of cells")
//            //            return UITableViewCell()
//        }
    }
    
}

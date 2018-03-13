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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
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
            let balance = WalletWeb3Factory.web3.eth.getBalance(address: self.address!, onBlock: "pending")
            if (balance.value == nil) {
                return cell
            }
            guard let formattedAmount = Web3.Utils.formatToEthereumUnits(balance.value!, toUnits: .eth, decimals: 3) else {return cell}
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
        switch indexPath.section {
        case 0:
            return
        case 1:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SendETHTableViewController") as! SendETHTableViewController
            controller.keystore = keystore
            controller.address = address
            self.navigationController?.pushViewController(controller, animated: true)
            return
        case 2:
            return
        default:
            fatalError("Invalid number of cells")
        }
    }
    
}

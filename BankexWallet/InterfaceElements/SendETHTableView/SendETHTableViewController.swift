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

class SendETHTableViewController: UITableViewController {
    
    @IBOutlet weak var destinationAddressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    
    var address: EthereumAddress? = nil
    var keystore: AbstractKeystore? = nil
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    let sendEthService: SendEthService = SendEthServiceImplementation()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
            switch indexPath.section {
            case 0:
                return
            case 1:
                return
            case 2:
                let destination = EthereumAddress(destinationAddressTextField.text!)
                guard destination.isValid else {return}
                guard let amountString = amountTextField.text else {return}
                guard let amount = Web3.Utils.parseToBigUInt(amountString, toUnits: .eth) else {return}
                let web3 = WalletWeb3Factory.web3
                if (self.keystore!.isHDKeystore) {
                    web3.addKeystoreManager(BankexWalletKeystores.BIP32KeystoresManager)
                } else {
                    web3.addKeystoreManager(BankexWalletKeystores.EthereumKeystoresManager)
                }
                var options = Web3Options.defaultOptions()
                options.gasLimit = BigUInt(21000)
                options.from = self.address
                options.value = BigUInt(amount)
                guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destination) else {return}
                guard let estimatedGas = contract.method(options: options)?.estimateGas(options: nil).value else {return}
                options.gasLimit = estimatedGas
                guard let gasPrice = web3.eth.getGasPrice().value else {return}
                options.gasPrice = gasPrice
                let transactionIntermediate = contract.method(options: options)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "ConfirmTransactionTableViewController") as! ConfirmTransactionTableViewController
                controller.intermediate = transactionIntermediate
                self.navigationController?.pushViewController(controller, animated: true)
                return
            default:
                fatalError("Invalid number of cells")
                //            return UITableViewCell()
            }
    }
    
}


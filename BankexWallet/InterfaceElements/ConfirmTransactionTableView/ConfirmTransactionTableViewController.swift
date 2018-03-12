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

class ConfirmTransactionTableViewController: UITableViewController {
    
    @IBOutlet weak var destinationAddressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var extraDataTextView: UITextView!
    @IBOutlet weak var gasLimitTextField: UITextField!
    @IBOutlet weak var gasPriceTextField: UITextField!

    var intermediate: TransactionIntermediate? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.destinationAddressTextField.text = self.intermediate?.transaction.to.address
        self.amountTextField.text = Web3.Utils.formatToEthereumUnits((self.intermediate?.options?.value)!)
        self.extraDataTextView.text = self.intermediate?.transaction.data.toHexString()
        self.gasLimitTextField.text = Web3.Utils.formatToEthereumUnits((self.intermediate?.options?.gasLimit)!, toUnits: .wei, decimals: 0)
        self.gasPriceTextField.text = Web3.Utils.formatToEthereumUnits((self.intermediate?.options?.gasPrice)!, toUnits: .wei, decimals: 0)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    let service: SendEthService = SendEthServiceImplementation()
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        switch indexPath.section {
        case 5:
            guard let intermediate = intermediate else {
                return
            }
            do {
                let result = try service.send(transaction: intermediate,
                                          with: "BANKEXFOUNDATION")
                let alert = UIAlertController.init(title: "Sent successfully",
                                                   message: "TX hash is " + (result["txhash"])!,
                                                   preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            catch {
                
            }

            return
        default:
            return
//            fatalError("Invalid number of cells")
        }
    }
    
}



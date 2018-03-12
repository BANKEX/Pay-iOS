//
//  TokenTransferContainerController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/6/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class TokenTransferContainerController: UIViewController, UIScrollViewDelegate {

    // MARK: Services
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    let sendEthService: SendEthService = SendEthServiceImplementation()
    let utilsService: UtilTransactionsService = UtilTransactionsServiceImplementation()
    
    // MARK: Outlets
    
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var ethAmountTextfield: UITextField!
    @IBOutlet weak var destinationTextfield: UITextField!    
    
    @IBAction func sendTransaction(_ sender: Any) {
        guard let amount = ethAmountTextfield.text,
            let destinationAddress = destinationTextfield.text else {
                return
        }
        sendEthService.prepareTransactionForSending(destinationAddressString: destinationAddress, amountString: amount) { (result) in
            switch result {
            case .Success(let transaction):
                self.showConfirmation(forSending: amount, destinationAddress: destinationAddress, transaction: transaction)
            case .Error(let error):
                print("\(error)")
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let selectedAddress = keysService.preferredSingleAddress() else {
            return
        }
        addressLabel.text = "Address: " + selectedAddress
        updateBalance()
    }
    
    // MARK: 
    @IBAction func endEditingTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    // MARK: ScrollView
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    // MARK: Confirmation Process
    
    func showConfirmation(forSending amount: String,
                          destinationAddress:String,
                          transaction: TransactionIntermediate) {
        let alertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to send \(amount) Eth. to \(destinationAddress)", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Sure", style: .default, handler: { (_) in
            self.confirm(transaction: transaction)
        }))
        alertController.addAction(UIAlertAction(title: "Let me think", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func confirm(transaction: TransactionIntermediate) {
        sendEthService.send(transaction: transaction) { (result) in
            switch result {
            case .Success(let response):
                let alertController = UIAlertController(title: "Succeed", message: "\(response)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                }))
                self.present(alertController, animated: true, completion: nil)
                self.updateBalance()
            case .Error(let error):
                print("\(error)")
            }
        }
    }
    
    // MARK: Balance
    func updateBalance() {
        guard let selectedAddress = keysService.preferredSingleAddress() else {
            return
        }
        utilsService.getBalance(for: selectedAddress) { (result) in
            switch result {
            case .Success(let response):
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                let formattedAmount = Web3.Utils.formatToEthereumUnits(response, toUnits: .eth, decimals: 0)
                self.currentBalanceLabel.text = "Amount: " + formattedAmount!
            case .Error(let error):
                print("\(error)")
            }
        }
    }
}

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
    //    @IBOutlet weak var amountTextfield: UITextField!
//    @IBOutlet weak var destinationAddressTextfield: UITextField!
    
    
    @IBAction func sendTransaction(_ sender: Any) {
        guard let amount = ethAmountTextfield.text,
            let destinationAddress = destinationTextfield.text else {
                return
        }
        
        do {
            let intermediate = try sendEthService.prepareTransactionForSending(
                destinationAddressString: destinationAddress,
                amountString: amount,
                gasLimit: 21000)
            
            let alertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to send \(amount) Eth. to \(destinationAddress)", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Sure", style: .default, handler: { (_) in
                self.confirm(transaction: intermediate)
            }))
            alertController.addAction(UIAlertAction(title: "Let me think", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        catch {
            
        }
    }
    
    func confirm(transaction: TransactionIntermediate) {
        do {
            let result = try sendEthService.send(transaction: transaction)
            let alertController = UIAlertController(title: "Succeed", message: "\(result)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            }))
            present(alertController, animated: true, completion: nil)
        }
        catch {
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let selectedAddress = keysService.preferredSingleAddress() else {
            return
        }
        addressLabel.text = "Address: " + selectedAddress
        do {
            let amount = try utilsService.getBalance(for: selectedAddress)
            // TODO: it shouldn't be here anyway and also, lets move to background thread
            let formattedAmount = Web3.Utils.formatToEthereumUnits(amount, toUnits: .eth, decimals: 0)
            currentBalanceLabel.text = "Amount: " + formattedAmount!
        }
        catch {
            
        }
    }
    
    // MARK: 
    @IBAction func endEditingTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    // MARK: ScrollView
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

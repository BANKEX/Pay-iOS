//
//  SendingConfirmationController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina (Agoda) on 4/8/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class SendingConfirmationController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var fromAddressLabel: UILabel!
    
    @IBOutlet weak var feeLabel: UILabel!
    
    // MARK:
    var transaction: TransactionIntermediate?
    var amount: String?
    var destinationAddress:String?
    var inputtedPassword: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        transaction?.send(password: inputtedPassword, options: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toAddressLabel.text = destinationAddress
        fromAddressLabel.text = SingleKeyServiceImplementation().selectedAddress()
        amountLabel.text = amount
        // TODO:  Need to be formatted
        feeLabel.text = "\(transaction?.estimateGas(options: nil).value)"
//        amountLabel.text =
//        let alertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to send \(amount) \(tokensService.selectedERC20Token().symbol). to \(destinationAddress)", preferredStyle: .alert)

    }
    

}

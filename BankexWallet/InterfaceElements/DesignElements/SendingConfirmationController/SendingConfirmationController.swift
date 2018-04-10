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
    
    weak var transactionCompletionDelegate: SendingResultInformation?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showSending",
            let destination = segue.destination as? SendingInProcessViewController else {
                return
        }
        transactionCompletionDelegate = destination
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    let tokensService = CustomERC20TokensServiceImplementation()
    let keysService: SingleKeyService = SingleKeyServiceImplementation()

    @IBAction func nextButtonTapped(_ sender: Any) {
        let sendEthService: SendEthService = tokensService.selectedERC20Token().address.isEmpty ?
            SendEthServiceImplementation() :
            ERC20TokenContractMethodsServiceImplementation()
        
        let token = tokensService.selectedERC20Token()
        let transactionModel = ETHTransactionModel(from: keysService.selectedAddress() ?? "",
                                                   to: destinationAddress ?? "",
                                                   amount: (amount ?? "") + " " + token.symbol,
                                                   date: Date(),
                                                   token: token,
                                                   key: keysService.selectedKey()!)

        
        performSegue(withIdentifier: "showSending", sender: self)
        sendEthService.send(transactionModel: transactionModel,
                            transaction: transaction!,
                            with: inputtedPassword ?? "") { (result) in
                                switch result {
                                case .Success(_):
                                    self.performSegue(withIdentifier: "showSuccess", sender: self)
                                case .Error(_):
                                    //TODO:
                                    self.performSegue(withIdentifier: "showError", sender: self)
                                }
//                                }
        }//transaction?.send(password: inputtedPassword ?? "", options: nil)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toAddressLabel.text = destinationAddress
        fromAddressLabel.text = SingleKeyServiceImplementation().selectedAddress()
        amountLabel.text = amount
        // TODO:  Need to be formatted
        feeLabel.text = "\(transaction?.estimateGas(options: nil).value)"
    }
    

}

//
//  SendingInProcessViewController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/8/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol SendingResultInformation: class {
    func transactionDidSucceed(withAmount: String, address: String)
    
    func transactionDidFail()
}

class SendingInProcessViewController: UIViewController,
SendingResultInformation {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SendingSuccessViewController {
            controller.transactionAmount = transactionAmount
            controller.addressToSend = recipientAddress
        }
    }

    var transactionAmount: String?
    var recipientAddress: String?
    func transactionDidSucceed(withAmount: String, address: String) {
        transactionAmount = withAmount
        recipientAddress = address
        performSegue(withIdentifier: "showSuccess", sender: self)
    }
    
    func transactionDidFail() {
        performSegue(withIdentifier: "showError", sender: self)
    }
    
}

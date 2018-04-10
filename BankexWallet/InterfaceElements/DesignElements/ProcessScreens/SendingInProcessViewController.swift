//
//  SendingInProcessViewController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina (Agoda) on 4/8/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol SendingResultInformation: class {
    func transactionDidSucceed()
    
    func transactionDidFail()
}

class SendingInProcessViewController: UIViewController,
SendingResultInformation {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func transactionDidSucceed() {
        performSegue(withIdentifier: "showSuccess", sender: self)
    }
    
    func transactionDidFail() {
        performSegue(withIdentifier: "showError", sender: self)
    }
    
}

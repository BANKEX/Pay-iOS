//
//  SendingErrorViewController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/8/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol Retriable {
    func retryExisitngTransaction()
}

class SendingErrorViewController: UIViewController {

    @IBAction func retryTransaction(_ sender: Any) {
        let count = navigationController?.viewControllers.count ?? 2
        if let previousController = navigationController?.viewControllers[count - 2] as? Retriable {
            previousController.retryExisitngTransaction()
        }
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func done(_ sender: Any) {
        navigationController?.popToRootViewController(animated: false)
    }
}

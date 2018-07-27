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
    
    var error: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let error = error {
            switch error {
            case "invalidAddress":
                print("address")
            case "insufficient funds for gas * price + value":
                print("insufficient funds for gas * price + value")
                
            default:
                break
            }
        }
        
        addBackButton()
    }
    
    @IBAction func retryTransaction(_ sender: Any) {
        let count = navigationController?.viewControllers.count ?? 3
        if  count >= 3, let previousController = navigationController?.viewControllers[count - 3] as? Retriable
        {
            previousController.retryExisitngTransaction()
            navigationController?.popToViewController(previousController as! UIViewController, animated: false)

        } else {
            navigationController?.popToRootViewController(animated: false)
        }
    }
    
    func addBackButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "BackArrow"), for: .normal)
        button.setTitle("  Home", for: .normal)
        button.setTitleColor(WalletColors.blueText.color(), for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(done(_:)), for: .touchUpInside)
    }
    
    @IBAction func done(_ sender: Any) {
        navigationController?.popToRootViewController(animated: false)
    }
}

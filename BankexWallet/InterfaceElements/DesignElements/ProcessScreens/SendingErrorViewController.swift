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
    
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackButton()
    }
    
    @IBAction func retryTransaction(_ sender: Any) {
        self.performSegue(withIdentifier:"unwindToSend", sender: error)
//        let count = navigationController?.viewControllers.count ?? 3
//
//        if  count >= 3, let previousController = navigationController?.viewControllers[count - 3] as? SendTokenViewController
//        {
//            //previousController.retryExisitngTransaction()
//            navigationController?.popToViewController(previousController as UIViewController, animated: false)
//
//        } else {
//            navigationController?.popToRootViewController(animated: false)
//        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SendTokenViewController {
            if error == nil {
                vc.retryExisitngTransaction()
            }
            vc.errorMessage = error
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

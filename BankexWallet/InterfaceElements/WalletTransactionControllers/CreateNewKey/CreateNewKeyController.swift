//
//  CreateNewKeyController.swift
//  web3swiftBrowser
//
//  Created by Korovkina, Ekaterina on 2/18/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class CreateNewKeyController: UIViewController {

    @IBOutlet weak var inputKeyTextView: UITextView!
    let keysService = SingleKeyServiceImplementation()
    
    @IBAction func addKeyFromTextView(_ sender: Any) {
        guard inputKeyTextView.text.count > 0 else {
            let alert = UIAlertController(title: "Error", message: "Please, input key", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            present(alert, animated: true, completion: nil)
            return
        }
        importKey(keyText: inputKeyTextView.text)
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func createNewKey(_ sender: Any) {
        createWallet()
        navigationController?.popViewController(animated: true)
    }


    // MARK: Create New Wallet
    func createWallet() {
        keysService.createNewSingleAddressWallet()
    }
    
    func importKey(keyText: String) {
        keysService.createNewSingleAddressWallet(fromText: keyText, password: "")
    }
}

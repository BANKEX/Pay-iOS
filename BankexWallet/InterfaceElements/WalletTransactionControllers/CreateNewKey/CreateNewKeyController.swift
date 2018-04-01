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
//        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func createNewKey(_ sender: Any) {
        createWallet()
    }


    // MARK: Create New Wallet
    func createWallet() {
        //TODO: Add name here
        keysService.createNewSingleAddressWallet(with: "", password: "BANKEXFOUNDATION") { (error) in
            self.navigationController?.popViewController(animated: true)//(with: "") { (error) in
        }//createNewSingleAddressWallet()
    }
    
    func importKey(keyText: String) {
        // TODO: add name
        keysService.createNewSingleAddressWallet(with: "", fromText: keyText, password: "BANKEXFOUNDATION") { (error) in
            self.navigationController?.popViewController(animated: true)
        }
    }
}

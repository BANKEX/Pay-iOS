//
//  CreateNewKeyController.swift
//  web3swiftBrowser
//
//  Created by Korovkina, Ekaterina on 2/18/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class CreateNewKeyController: UIViewController {

    @IBOutlet weak var inputKeyTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addKeyFromTextView(_ sender: Any) {
        guard inputKeyTextView.text.characters.count > 0 else {
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
        guard let newWallet = try? EthereumKeystoreV3(password: "BANKEXFOUNDATION") else {return}
        guard let wallet = newWallet, wallet.addresses != nil, wallet.addresses?.count == 1 else {return}
        guard let keydata = try? JSONEncoder().encode(wallet.keystoreParams) else {return}
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        guard let address = newWallet?.addresses?.first?.address else {return}
        let path = userDir + "/keystore"
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        var exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        if (!exists && !isDir.boolValue){
            try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        }
        if (!isDir.boolValue) {
            return
        }
        FileManager.default.createFile(atPath: path + "/" + address + ".json", contents: keydata, attributes: nil)
    }
    
    func importKey(keyText: String) {
        let text = keyText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard let data = Data.fromHex(text) else {return}
        guard let newWallet = try? EthereumKeystoreV3(privateKey:data) else {return}
        guard let wallet = newWallet, wallet.addresses != nil, wallet.addresses?.count == 1 else {return}
        guard let keydata = try? JSONEncoder().encode(wallet.keystoreParams) else {return}
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        guard let address = newWallet?.addresses?.first?.address else {return}
        let path = userDir + "/keystore"
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        var exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        if (!exists && !isDir.boolValue){
            try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        }
        if (!isDir.boolValue) {
            return
        }
        FileManager.default.createFile(atPath: path + "/" + address + ".json", contents: keydata, attributes: nil)
    }
}

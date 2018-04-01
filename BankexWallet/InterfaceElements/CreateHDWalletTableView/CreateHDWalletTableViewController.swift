//
//  SingleAddressTableViewController.swift
//  BankexWallet
//
//  Created by Alexander Vlasov on 29.01.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import web3swift
import BigInt

class CreateHDWalletTableViewController: UITableViewController {
    @IBOutlet weak var seedPhraseTextView: UITextView!
    @IBOutlet weak var encryptionPasswordTextField: UITextField!
    @IBOutlet weak var seedPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let seedPhrase = try? BIP39.generateMnemonics(bitsOfEntropy: 128, language: .english) else {fatalError("Fatal")}
        if seedPhrase == nil {
            fatalError("Fatal")
        }
        self.seedPhraseTextView.text = seedPhrase!
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if indexPath.section != 3 {return}
        switch indexPath.row {
        case 0:
            guard let mnemonics = self.seedPhraseTextView.text else {return}
            guard let encryptionPassword = self.encryptionPasswordTextField.text else {return}
            guard let mnemonicsPassword = self.seedPasswordTextField.text else {return}
            guard let newWallet = try? BIP32Keystore(mnemonics: mnemonics, password: encryptionPassword, mnemonicsPassword: mnemonicsPassword, language: .english) else {return}
            guard let wallet = newWallet, wallet.addresses != nil, wallet.addresses?.count == 1 else {return}
            guard let keydata = try? JSONEncoder().encode(wallet.keystoreParams) else {return}
            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            guard let address = wallet.addresses?.first?.address else {return}
            let path = userDir + BankexWalletConstants.BIP32KeystoreStoragePath
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
            guard let navigationStack = self.navigationController?.viewControllers else {return}
            for controller in navigationStack {
                if let mainView = controller as? WalletsTableViewController {
                    self.navigationController?.popToViewController(mainView, animated: true)
                    return
                } else {
                    continue
                }
            }
        default:
            return
            //            fatalError("Invalid number of cells")
        }
    }
    
}




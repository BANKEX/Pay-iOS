//
//  BackupPassphraseViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class BackupPassphraseViewController: UIViewController {
    @IBOutlet weak var passphraseLabel: UILabel!
    let service: HDWalletService = HDWalletServiceImplementation()
    var passphrase: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        passphrase = service.generateMnemonics(bitsOfEntropy: 128)
        passphraseLabel.text = passphrase
    }
    
    @IBAction func copyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = passphrase
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let repeatPasshraseVC = segue.destination as? RepeatPassphraseViewController {
            repeatPasshraseVC.passphrase = passphrase
        }
    }
}

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
    @IBOutlet weak var passphraseCopiedView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    let service: HDWalletService = HDWalletServiceImplementation()
    var passphrase: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Creating Wallet"
        passphrase = service.generateMnemonics()
        passphraseLabel.text = passphrase
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        passphraseCopiedView.alpha = 0.0
        if passphrase != UIPasteboard.general.string {
            nextButton.isEnabled = false
            nextButton.backgroundColor = WalletColors.disabledGreyButton.color()
        }
        
        
    }
    
    @IBAction func copyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = passphrase
        
        UIView.animate(withDuration: 0.5, animations: {
            self.passphraseCopiedView.alpha = 1.0
            self.nextButton.backgroundColor = WalletColors.blueText.color()
        }) { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                self.passphraseCopiedView.alpha = 0.0
            }, completion: nil)
        }
        
        nextButton.isEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let repeatPasshraseVC = segue.destination as? RepeatPassphraseViewController {
            repeatPasshraseVC.passphrase = passphrase
            repeatPasshraseVC.service = service
        }
    }
}

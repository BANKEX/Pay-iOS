//
//  BackupPassphraseViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class BackupPassphraseViewController: UIViewController {
    
    @IBOutlet weak var passphraseLabel: UILabel!
    @IBOutlet weak var passphraseCopiedView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    let service: HDWalletService = HDWalletServiceImplementation()
    var passphrase: String?
    var navTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passphrase = service.generateMnemonics()
        passphraseLabel.text = passphrase
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarSetup()
        passphraseCopiedView.alpha = 0.0
        if passphrase != UIPasteboard.general.string {
            nextButton?.isEnabled = false
            nextButton?.backgroundColor = WalletColors.disabledGreyButton.color()
        }
        
    }
    
    @IBAction func copyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = passphrase
        
        UIView.animate(withDuration: 0.5, animations: {
            self.passphraseCopiedView.alpha = 1.0
            self.nextButton?.backgroundColor = WalletColors.blueText.color()
        }) { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                self.passphraseCopiedView.alpha = 0.0
            }, completion: nil)
        }
        
        nextButton?.isEnabled = true
    }
    
    func navigationBarSetup() {
        navigationItem.title = navTitle ?? "Creating Wallet"
        navigationController?.navigationBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let repeatPasshraseVC = segue.destination as? RepeatPassphraseViewController {
            repeatPasshraseVC.passphrase = passphrase
            repeatPasshraseVC.service = service
        }
    }
}

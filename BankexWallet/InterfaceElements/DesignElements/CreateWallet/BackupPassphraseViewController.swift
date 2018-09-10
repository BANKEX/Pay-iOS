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
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var lookOutView:UIView!
    @IBOutlet weak var copyButton:UIButton!
    @IBOutlet weak var bottomContraint:NSLayoutConstraint!
    @IBOutlet weak var clipboardView:UIView!
    
    let service: HDWalletService = HDWalletServiceImplementation()
    var passphrase: String?
    var navTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lookOutView.backgroundColor = WalletColors.errorColor
        passphrase = service.generateMnemonics()
        passphraseLabel.text = passphrase
        copyButton.backgroundColor = WalletColors.mainColor
        clipboardView.backgroundColor = WalletColors.clipboardColor
        clipboardView.alpha = 0
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarSetup()
        if passphrase != UIPasteboard.general.string {
            nextButton?.isEnabled = false
            nextButton?.backgroundColor = WalletColors.disableColor
        }
        
    }
    
    @IBAction func copyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = passphrase
        
        UIView.animate(withDuration: 0.7, animations: {
            self.nextButton?.backgroundColor = WalletColors.mainColor
            self.clipboardView.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 0.7, animations: {
                self.clipboardView.alpha = 0
            })
        }
        
        nextButton?.isEnabled = true
    }
    
    func navigationBarSetup() {
        let label = UILabel()
        label.text = NSLocalizedString("Creating Wallet", comment: "")
        label.textColor = UIColor.white
        navigationItem.title = navTitle ?? NSLocalizedString("Creating Wallet", comment: "")
        navigationItem.titleView = label
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = WalletColors.errorColor
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.rightBarButtonItem  = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
    }
    
    @objc func share() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let repeatPasshraseVC = segue.destination as? RepeatPassphraseViewController {
            repeatPasshraseVC.passphrase = passphrase
            repeatPasshraseVC.service = service
        }
    }
}

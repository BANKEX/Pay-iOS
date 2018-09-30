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
    @IBOutlet weak var bottomButtonContraint:NSLayoutConstraint!
    @IBOutlet weak var titleLbl:UILabel!
    
    let service: HDWalletService = HDWalletServiceImplementation()
    var passphrase: String?
    var navTitle: String?
    var fromSettings:Bool {
        if let _ = navTitle {
            return true
        }
        return false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        lookOutView.backgroundColor = WalletColors.errorColor
        passphrase = service.generateMnemonics()
        passphraseLabel.text = passphrase
        copyButton.backgroundColor = WalletColors.mainColor
        clipboardView.backgroundColor = WalletColors.clipboardColor
        bottomContraint.constant = 100.0
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarSetup()
        nextButton.isHidden = fromSettings ? true : false
        if fromSettings {
            nextButton.isHidden = true
            bottomButtonContraint.constant = -50.0
        }else {
            nextButton.isHidden = false
            bottomButtonContraint.constant = 16.0
        }
        if passphrase != UIPasteboard.general.string {
            nextButton?.isEnabled = false
            nextButton?.backgroundColor = WalletColors.disableColor
        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.statusBarView?.backgroundColor = .white
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.barTintColor = .white
    }
    
    @IBAction func copyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = passphrase
        self.nextButton?.backgroundColor = WalletColors.mainColor
        
        UIView.animate(withDuration: 0.7,animations: {
            if #available(iOS 11.0, *) {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let bottomInset = appDelegate.window?.safeAreaInsets.bottom
                self.bottomContraint.constant = bottomInset!
            }else {
               self.bottomContraint.constant = 0
            }
            
            self.view.layoutIfNeeded()
        }) { (_) in
            UIView.animate(withDuration: 0.7,delay:0.5,animations: {
                self.bottomContraint.constant = 100
                self.view.layoutIfNeeded()
            })
        }
        
        
        nextButton?.isEnabled = true
    }
    
    func navigationBarSetup() {
        titleLbl.text = navTitle ?? "Create Wallet"
        navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.statusBarView?.backgroundColor = WalletColors.errorColor
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func share() {
        guard let passphrase = passphraseLabel.text else { return }
        let activityVC = UIActivityViewController(activityItems: [passphrase], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let repeatPasshraseVC = segue.destination as? RepeatPassphraseViewController {
            repeatPasshraseVC.passphrase = passphrase
            repeatPasshraseVC.service = service
        }
    }
    
    @IBAction func back() {
        navigationController?.popViewController(animated: true)
    }
}

//
//  BackupPassphraseViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
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
    var isAnimating = false
    override func viewDidLoad() {
        super.viewDidLoad()
        lookOutView.backgroundColor = UIColor.errorColor
        passphrase = service.generateMnemonics()
        passphraseLabel.text = passphrase
        copyButton.backgroundColor = .white
        copyButton.layer.borderWidth = 2
        copyButton.layer.borderColor = UIColor.mainColor.cgColor
        clipboardView.backgroundColor = UIColor.clipboardColor
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
            nextButton?.backgroundColor = UIColor.lightBlue
        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.statusBarStyle = .default
        UIApplication.shared.statusBarView?.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
    }
    
    @IBAction func copyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = passphrase
        self.nextButton?.backgroundColor = UIColor.mainColor
        if !isAnimating {
            isAnimating = true
            UIView.animate(withDuration: 0.6,animations: {
                if #available(iOS 11.0, *) {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let bottomInset = appDelegate.window?.safeAreaInsets.bottom
                    self.bottomContraint.constant = bottomInset!
                }else {
                    self.bottomContraint.constant = 0
                }
                
                self.view.layoutIfNeeded()
            }) { (_) in
                UIView.animate(withDuration: 0.6,delay:0.5,animations: {
                    self.bottomContraint.constant = 100
                    self.view.layoutIfNeeded()
                }) { _ in
                    self.isAnimating = false
                }
            }
        }
        
        
        
        nextButton?.isEnabled = true
    }
    
    func navigationBarSetup() {
        title = NSLocalizedString("Back", comment: "")
        titleLbl.text = navTitle ?? NSLocalizedString("Create Wallet", comment: "")
        navigationController?.setNavigationBarHidden(true, animated: true)
        statusBarColor(UIColor.errorColor)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func share() {
        guard let passphrase = passphraseLabel.text else { return }
        let activityVC = UIActivityViewController(activityItems: [passphrase], applicationActivities: nil)
        activityVC.addPopover(in: view, rect: CGRect(x: view.bounds.width - 34, y: 0, width: 0, height: 0), .up)
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

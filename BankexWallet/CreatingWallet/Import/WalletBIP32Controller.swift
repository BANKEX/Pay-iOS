//
//  WalletBIP32Controller.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import Amplitude_iOS
import GrowingTextView

class WalletBIP32Controller: BaseViewController,UITextFieldDelegate,ScreenWithContentProtocol,GrowingTextViewDelegate {
    
    
    enum State {
        case notAvailable,available
    }
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var importButton:UIButton!
    @IBOutlet weak var nameTextField:UITextField!
    @IBOutlet weak var separator2:UIView!
    @IBOutlet weak var separator1:UIView!
    @IBOutlet weak var passphraseTextView:GrowingTextView!
    @IBOutlet weak var clearButton:UIButton!
    @IBOutlet weak var pasteButton:PasteButton!
    @IBOutlet weak var activityView:UIActivityIndicatorView!
    @IBOutlet weak var containerView:UIView!
    
    //MARK: - Properties
    let service = HDWalletServiceImplementation()
    let router = WalletCreationTypeRouterImplementation()
    var state:State = .notAvailable {
        didSet {
            if state == .notAvailable {
                clearButton.isHidden = true
                importButton.isEnabled = false
                importButton.backgroundColor = UIColor.lightBlue
                passphraseTextView.returnKeyType = .next
            }else {
                clearButton.isHidden = false
                importButton.isEnabled = true
                importButton.backgroundColor = UIColor.mainColor
                passphraseTextView.returnKeyType = .done
            }
        }
    }

    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        configure()
        state = .notAvailable
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    //MARK: - Methods
    func clearTextFields() {
        nameTextField.text = ""
        passphraseTextView.text = ""
        view.endEditing(true)
        if passphraseTextView.text.utf16.count > 0  {
            state = .notAvailable
        }
    }
    
    func configure() {
        nameTextField.delegate = self
        passphraseTextView.delegate = self
        passphraseTextView.placeholder = NSLocalizedString("Enter your seed phrase", comment: "")
        passphraseTextView.placeholderColor = UIColor.setColorForTextViewPlaceholder()
        passphraseTextView.trimWhiteSpaceWhenEndEditing = false
        passphraseTextView.autocorrectionType = .no
        passphraseTextView.autocapitalizationType = .none
        nameTextField.autocorrectionType = .no
    }
    
    
    //MARK: - IBActions
    @IBAction func clearTextView(_ sender:Any) {
        passphraseTextView.text = ""
        state = .notAvailable
    }
    
    @IBAction func stringFromBuffer(_ sender:UIButton) {
        if let string = UIPasteboard.general.string  {
            passphraseTextView.text = string
            state = .available
        }
    }
    
    @IBAction func createWalletTapped(_ sender:Any) {
        if UIDevice.isIpad {
            if !UserDefaults.standard.bool(forKey: "passcodeExists") {
                let passcodeLock = CreateVC(byName: "PasscodeIpadVC") as! PasscodeIpadVC
                passcodeLock.delegate = self
                passcodeLock.modalPresentationStyle = .formSheet
                passcodeLock.preferredContentSize = CGSize(width: 320, height: 600)
                present(passcodeLock, animated: true, completion: nil)
            }else {
                showLoading()
                let generatedPassphrase = passphraseTextView.text!
                let nameWallet = nameTextField.text ?? ""
                service.createNewHDWallet(with: nameWallet, mnemonics: generatedPassphrase, mnemonicsPassword: "", walletPassword: "BANKEXFOUNDATION") { (_, error) in
                    guard error == nil else {
                        self.showCreationAlert()
                        return
                    }
                    Amplitude.instance().logEvent("Wallet Imported")
                    self.hideLoading()
                    self.performSegue(withIdentifier: "showProcessFromImportPassphrase", sender: self)
                }
            }
        }else {
            showLoading()
            let generatedPassphrase = passphraseTextView.text!
            let nameWallet = nameTextField.text ?? ""
            service.createNewHDWallet(with: nameWallet, mnemonics: generatedPassphrase, mnemonicsPassword: "", walletPassword: "BANKEXFOUNDATION") { (_, error) in
                guard error == nil else {
                    self.showCreationAlert()
                    return
                }
                Amplitude.instance().logEvent("Wallet Imported")
                self.hideLoading()
                if !UserDefaults.standard.bool(forKey: "passcodeExists") {
                    self.performSegue(withIdentifier: "goToPinFromImportPassphrase", sender: self)
                } else {
                    self.performSegue(withIdentifier: "showProcessFromImportPassphrase", sender: self)
                }
            }
        }
    }
    
    
    
    
    
    func showLoading() {
        UIView.animate(withDuration: 0.1) {
            self.containerView.alpha = 1.0
        }
        self.activityView.startAnimating()
    }
    
    func hideLoading() {
        UIView.animate(withDuration: 0.1) {
            self.containerView.alpha = 0
        }
        self.activityView.stopAnimating()
    }
    
    
    
    //MARK: - Delegate_TextField
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        textField.returnKeyType = importButton.isEnabled ? .done : .next
        separator2.backgroundColor = UIColor.mainColor
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        separator2.backgroundColor = UIColor.separatorColor
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done && importButton.isEnabled {
            createWalletTapped(self)
        }else if textField.returnKeyType == .next {
            passphraseTextView.becomeFirstResponder()
        }
        return true
    }
    
    
    
    //MARK: - TextViewDelegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        separator1.backgroundColor = UIColor.mainColor
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 {
            state = .available
            if textView == passphraseTextView && textView.text.isEmpty {
                if text.utf16.count == 0 {
                    return false
                }
            }
            return true
        }else {
            state = .notAvailable
            textView.text = ""
            return false
        }
    }
    
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        separator1.backgroundColor = UIColor.separatorColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PasscodeLockController {
            destinationViewController.newWallet = false
        }
        if let vc = segue.destination as? SendingInProcessViewController {
            vc.fromEnterScreen = true
        }
    }

}


extension WalletBIP32Controller:PasscodeIpadVCDelegate {
    func didCreate() {
        showLoading()
        let generatedPassphrase = passphraseTextView.text!.replacingOccurrences(of: "\n", with: "")
        let nameWallet = nameTextField.text ?? ""
        service.createNewHDWallet(with: nameWallet, mnemonics: generatedPassphrase, mnemonicsPassword: "", walletPassword: "BANKEXFOUNDATION") { (_, error) in
            guard error == nil else {
                self.showCreationAlert()
                return
            }
            Amplitude.instance().logEvent("Wallet Imported")
            self.hideLoading()
            self.router.exitFromTheScreeniPad()
            }
        }
    }





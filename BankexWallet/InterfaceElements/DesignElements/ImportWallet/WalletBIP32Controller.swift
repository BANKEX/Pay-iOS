//
//  WalletBIP32Controller.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class WalletBIP32Controller: UIViewController,UITextFieldDelegate,ScreenWithContentProtocol,UITextViewDelegate {
    
    
    enum State {
        case notAvailable,available
    }
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var importButton:UIButton!
    @IBOutlet weak var nameTextField:UITextField!
    @IBOutlet weak var separator2:UIView!
    @IBOutlet weak var separator1:UIView!
    @IBOutlet weak var passphraseTextView:UITextView!
    @IBOutlet weak var clearButton:UIButton!
    
    
    //MARK: - Properties
    let service = HDWalletServiceImplementation()
    let router = WalletCreationTypeRouterImplementation()
    var state:State = .notAvailable {
        didSet {
            if state == .notAvailable {
                clearButton.isHidden = true
                importButton.isEnabled = false
                importButton.backgroundColor = WalletColors.defaultGreyText.color()
                passphraseTextView.returnKeyType = .next
            }else {
                clearButton.isHidden = false
                importButton.isEnabled = true
                importButton.backgroundColor = WalletColors.blueText.color()
                passphraseTextView.returnKeyType = .done
            }
        }
    }

    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        state = .notAvailable
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let text = passphraseTextView.text {
            if text == "\n" {
                passphraseTextView.applyPlaceHolderText(with: "Enter your passphrase")
            }
        }
        view.endEditing(true)
    }
    
    
    
    //MARK: - Methods
    func clearTextFields() {
        nameTextField.text = ""
        passphraseTextView.applyPlaceHolderText(with: "Enter your passphrase")
        view.endEditing(true)
        if passphraseTextView.text.utf16.count > 0  {
            state = .notAvailable
        }
    }
    
    func configure() {
        nameTextField.delegate = self
        passphraseTextView.delegate = self
        passphraseTextView.contentInset.bottom = 10.0
        passphraseTextView.applyPlaceHolderText(with: "Enter your passphrase")
        passphraseTextView.autocorrectionType = .no
        passphraseTextView.autocapitalizationType = .none
        nameTextField.autocorrectionType = .no
    }
    

    
    //MARK: - IBActions
    @IBAction func clearTextView(_ sender:Any) {
        passphraseTextView.applyPlaceHolderText(with: "Enter your passphrase")
        state = .notAvailable
        passphraseTextView.moveCursorToStart()
    }
    
    @IBAction func stringFromBuffer(_ sender:UIButton) {
        if let string = UIPasteboard.general.string  {
            passphraseTextView.text = string
            passphraseTextView.textColor = .black
            state = .available
        }
    }
    
    @IBAction func createWalletTapped(_ sender:Any) {
        let generatedPassphrase = passphraseTextView.text!
        let nameWallet = nameTextField.text ?? ""
        service.createNewHDWallet(with: nameWallet, mnemonics: generatedPassphrase, mnemonicsPassword: "", walletPassword: "") { (_, error) in
            guard error == nil else {
                self.showCreationAlert()
                return
            }
            self.router.exitFromTheScreen()
        }
    }
    
    
    
    //MARK: - Delegate_TextField
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        textField.returnKeyType = importButton.isEnabled ? .done : .next
        separator2.backgroundColor = WalletColors.blueText.color()
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        separator2.backgroundColor = WalletColors.greySeparator.color()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done && importButton.isEnabled {
            createWalletTapped(self)
        }else if textField.returnKeyType == .next {
            passphraseTextView.applyNotHolder()
            passphraseTextView.becomeFirstResponder()
        }
        return true
    }
    
    
    
    //MARK: - TextViewDelegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        separator1.backgroundColor = WalletColors.blueText.color()
        return true
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView == passphraseTextView else { return  }
        guard textView.text == "Enter your passphrase" else { return  }
        passphraseTextView.moveCursorToStart()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 {
            state = .available
            if textView == passphraseTextView && textView.text == "Enter your passphrase" {
                if text.utf16.count == 0 {
                    return false
                }
                textView.applyNotHolder()
            }
            return true
        }else {
            state = .notAvailable
            textView.applyPlaceHolderText(with: "Enter your passphrase")
            passphraseTextView.moveCursorToStart()
            return false
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        separator1.backgroundColor = WalletColors.greySeparator.color()
    }
    
    
    

}

extension UITextView {
    func applyPlaceHolderText(with placeholder:String) {
        self.text = placeholder
        self.textColor = WalletColors.setColorForTextViewPlaceholder()
    }
    
    func applyNotHolder() {
        self.text = ""
        self.textColor = UIColor.black
    }
    
    func moveCursorToStart() {
        DispatchQueue.main.async {
            self.selectedRange = NSMakeRange(0, 0)
        }
    }
}


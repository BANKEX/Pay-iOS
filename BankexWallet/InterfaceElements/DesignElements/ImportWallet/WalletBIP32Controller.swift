//
//  WalletBIP32Controller.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class WalletBIP32Controller: UIViewController,UITextFieldDelegate,ScreenWithContentProtocol,UITextViewDelegate {
    
    
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

    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        importButton.isEnabled = false
        nameTextField.delegate = self
        passphraseTextView.delegate = self
        passphraseTextView.contentInset.bottom = 10.0
        passphraseTextView.applyPlaceHolderText(with: "Enter your passphrase")
        clearButton.isHidden = true
        passphraseTextView.autocorrectionType = .no
        passphraseTextView.autocapitalizationType = .none
        nameTextField.autocorrectionType = .no
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    //MARK: - Methods
    func clearTextFields() {
        nameTextField.text = ""
        passphraseTextView.applyPlaceHolderText(with: "Enter your passphrase")
        view.endEditing(true)
    }
    
    func showCreationAlert() {
        let alertViewController = UIAlertController(title: "Error", message: "Couldn't add key", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertViewController, animated: true)
    }
    
    
    
    
    
    
    //MARK: - IBActions
    @IBAction func clearTextView(_ sender:Any) {
        passphraseTextView.applyPlaceHolderText(with: "Enter your passphrase")
        clearButton.isHidden = true
        passphraseTextView.moveCursorToStart()
        importButton.isEnabled = false
        importButton.backgroundColor = WalletColors.defaultGreyText.color()
    }
    
    @IBAction func createWalletTapped(_ sender:Any) {
        let generatedPassphrase = passphraseTextView.text!
        service.createNewHDWallet(with: nameTextField.text ?? "", mnemonics: generatedPassphrase, mnemonicsPassword: "", walletPassword: "") { (_, error) in
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
            passphraseTextView.becomeFirstResponder()
        }else {
            view.endEditing(true)
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
            importButton.isEnabled = true
            textView.returnKeyType = importButton.isEnabled ? .done : .next
            importButton.backgroundColor = importButton.isEnabled ? WalletColors.blueText.color():WalletColors.defaultGreyText.color()
            clearButton.isHidden = false
            if textView == passphraseTextView && textView.text == "Enter your passphrase" {
                if text.utf16.count == 0 {
                    return false
                }
                textView.applyNotHolder()
            }
            return true
        }else {
            importButton.backgroundColor = WalletColors.defaultGreyText.color()
            importButton.isEnabled = false
            clearButton.isHidden = true
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
        self.textColor = UIColor.lightGray
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

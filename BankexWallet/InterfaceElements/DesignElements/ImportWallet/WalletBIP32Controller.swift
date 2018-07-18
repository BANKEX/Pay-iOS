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
    @IBOutlet var textFields:[UITextField]!
    @IBOutlet var separators:[UIView]!
    @IBOutlet weak var separator1:UIView!
    @IBOutlet weak var passwordTextField:UITextField!
    @IBOutlet weak var repeatPasswordTextField:UITextField!
    @IBOutlet weak var passphraseTextView:UITextView!
    
    
    //MARK: - Properties
    let service = HDWalletServiceImplementation()

    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        importButton.isEnabled = false
        textFields.forEach { $0.delegate = self }
        passphraseTextView.delegate = self
        passphraseTextView.contentInset.bottom = 10.0
        passphraseTextView.applyPlaceHolderText(with: "Enter your passphrase")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Methods
    func clearTextFields() {
        textFields.forEach {
            $0.text = ""
        }
        view.endEditing(true)
    }
    
    func moveCursorToStart(_ textView:UITextView) {
        DispatchQueue.main.async {
            textView.selectedRange = NSMakeRange(0, 0)
        }
    }
    
    
    @objc func keyboardHide(_ notification:Notification) {
        //TODO
    }
    
    @objc func keyboardShow(_ notification:Notification) {
        //TODO
    }
    
    //MARK: - IBActions
    @IBAction func changeVisibility(_ sender:Any) {
        //TODO
    }
    
    //MARK: - Delegate_TextField
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        textField.returnKeyType = importButton.isEnabled ? .done : .next
        let index = textFields.index(of: textField) ?? 0
        separators[index].backgroundColor = WalletColors.blueText.color()
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = textFields.index(of: textField) ?? 0
        let currentSeparator = separators[index]
        currentSeparator.backgroundColor = WalletColors.greySeparator.color()
        
        guard textField == passwordTextField || textField == repeatPasswordTextField else { return  }
        
        if !(passwordTextField.text?.isEmpty ?? true) && !(repeatPasswordTextField.text?.isEmpty ?? true) && passwordTextField.text != repeatPasswordTextField.text {
            let indexPswTF = textFields.index(of: passwordTextField) ?? 0
            let indexRepeatPswTF = textFields.index(of: repeatPasswordTextField) ?? 0
            separators[indexPswTF].backgroundColor = WalletColors.errorRed.color()
            separators[indexRepeatPswTF].backgroundColor = WalletColors.errorRed.color()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done && importButton.isEnabled {
            //Create Wallet
        }else if textField.returnKeyType == .next {
            let indexTF = textFields.index(of: textField) ?? 0
            let nextIndex = (textFields.count - 1) == indexTF ? 0 : indexTF + 1
            textFields[nextIndex].becomeFirstResponder()
        }else {
            view.endEditing(true)
        }
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        separator1.backgroundColor = WalletColors.blueText.color()
        return true
    }
    
    //MARK: - TextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView == passphraseTextView else { return  }
        guard textView.text == "Enter your passphrase" else { return  }
        moveCursorToStart(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 {
            if textView == passphraseTextView && textView.text == "Enter your passphrase" {
                if text.utf16.count == 0 {
                    return false
                }
                textView.applyNotHolder()
            }
            return true
        }else {
            textView.applyPlaceHolderText(with: "Enter your passphrase")
            moveCursorToStart(textView)
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
}

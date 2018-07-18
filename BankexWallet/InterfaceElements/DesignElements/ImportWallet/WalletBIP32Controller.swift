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

    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        importButton.isEnabled = false
        nameTextField.delegate = self
        passphraseTextView.delegate = self
        passphraseTextView.contentInset.bottom = 10.0
        passphraseTextView.applyPlaceHolderText(with: "Enter your passphrase")
        clearButton.isHidden = true
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
    
    func moveCursorToStart(_ textView:UITextView) {
        DispatchQueue.main.async {
            textView.selectedRange = NSMakeRange(0, 0)
        }
    }
    
    
    //MARK: - IBActions
    @IBAction func clearTextView(_ sender:Any) {
        passphraseTextView.applyPlaceHolderText(with: "Enter your passphrase")
        clearButton.isHidden = true
        moveCursorToStart(passphraseTextView)
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
            //Create Wallet
        }else if textField.returnKeyType == .next {
            passphraseTextView.becomeFirstResponder()
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
            clearButton.isHidden = false
            if textView == passphraseTextView && textView.text == "Enter your passphrase" {
                if text.utf16.count == 0 {
                    return false
                }
                textView.applyNotHolder()
            }
            return true
        }else {
            clearButton.isHidden = true
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

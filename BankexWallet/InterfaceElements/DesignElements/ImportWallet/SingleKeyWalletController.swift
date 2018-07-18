//
//  SingleKeyWalletController.swift
//  BankexWallet
//
//  Created by Vladislav on 18.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class SingleKeyWalletController: UIViewController,UITextFieldDelegate,ScreenWithContentProtocol,UITextViewDelegate {
    
    
    
    
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var clearButton:UIButton!
    @IBOutlet weak var privateKeyTextView:UITextView!
    @IBOutlet weak var singleKeyView:UIView!
    @IBOutlet weak var separator1:UIView!
    @IBOutlet weak var separator2:UIView!
    @IBOutlet weak var importButton:UIButton!
    
    
    //MARK: - Properties
    
    
    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        importButton.isEnabled = false
        privateKeyTextView.delegate = self
        privateKeyTextView.contentInset.bottom = 10.0
        privateKeyTextView.applyPlaceHolderText(with: "Enter your private key")
        clearButton.isHidden = true
        privateKeyTextView.autocorrectionType = .no
        privateKeyTextView.autocapitalizationType = .none
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    //MARK: - Methods
    
    func clearTextFields() {
        //TODO
    }
    
    //MARK: - IBActions
    @IBAction func clearTextView(_ sender:Any) {
        privateKeyTextView.applyPlaceHolderText(with: "Enter your private key")
        clearButton.isHidden = true
        privateKeyTextView.moveCursorToStart()
        importButton.isEnabled = false
        importButton.backgroundColor = importButton.isEnabled ? WalletColors.blueText.color() : WalletColors.defaultGreyText.color()
    }
    
    @IBAction func textFromBuffer(_ sender:Any) {
        if let string = UIPasteboard.general.string {
            privateKeyTextView.text = string
            clearButton.isHidden = false
        }
    }
    
    
    
    //MARK: - Delegate_TextField
    
    
    //MARK: - TextViewDelegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        separator1.backgroundColor = WalletColors.blueText.color()
        return true
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView == privateKeyTextView else { return  }
        guard textView.text == "Enter your private key" else { return  }
        privateKeyTextView.moveCursorToStart()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 {
            importButton.isEnabled = true
            importButton.backgroundColor = importButton.isEnabled ? WalletColors.blueText.color() : WalletColors.defaultGreyText.color()
            textView.returnKeyType = importButton.isEnabled ? .done : .next
            clearButton.isHidden = false
            if textView == privateKeyTextView && textView.text == "Enter your private key" {
                if text.utf16.count == 0 {
                    return false
                }
                textView.applyNotHolder()
            }
            return true
        }else {
            importButton.isEnabled = false
            importButton.backgroundColor = importButton.isEnabled ? WalletColors.blueText.color() : WalletColors.defaultGreyText.color()
            clearButton.isHidden = true
            textView.applyPlaceHolderText(with: "Enter your private key")
            privateKeyTextView.moveCursorToStart()
            return false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        separator1.backgroundColor = WalletColors.greySeparator.color()
    }
    
    
}

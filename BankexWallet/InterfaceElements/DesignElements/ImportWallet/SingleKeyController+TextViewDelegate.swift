//
//  SingleKeyController+TextViewDelegate.swift
//  BankexWallet
//
//  Created by Vladislav on 19.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

extension SingleKeyWalletController: UITextViewDelegate {
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

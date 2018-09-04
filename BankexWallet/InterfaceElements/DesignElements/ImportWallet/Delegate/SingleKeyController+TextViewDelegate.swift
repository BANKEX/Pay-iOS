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
        textView.returnKeyType = importButton.isEnabled ? .done : .next
        separator1.backgroundColor = WalletColors.blueText.color()
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.text == "Enter your private key" {
            textView.moveCursorToStart()
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView == privateKeyTextView else { return  }
        guard textView.text == NSLocalizedString("Enter your private key", comment: "") else { return  }
        privateKeyTextView.moveCursorToStart()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 {
            state = .available
            if textView == privateKeyTextView && textView.text == NSLocalizedString("Enter your private key", comment: "") {
                if text.utf16.count == 0 {
                    return false
                }
                textView.applyNotHolder()
            }
            return true
        }else {
            state = .notAvailable
            textView.applyPlaceHolderText(with: NSLocalizedString("Enter your private key", comment: ""))
            privateKeyTextView.moveCursorToStart()
            return false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        separator1.backgroundColor = WalletColors.greySeparator.color()
    }
}

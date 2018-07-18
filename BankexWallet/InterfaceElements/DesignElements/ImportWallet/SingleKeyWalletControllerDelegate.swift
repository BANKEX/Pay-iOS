//
//  SingleKeyWalletControllerDelegate.swift
//  BankexWallet
//
//  Created by Vladislav on 19.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit


extension SingleKeyWalletController:SingleKeyViewDelegate {
    
    func tfShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done && importButton.isEnabled {
            //Create Wallet
        }else if textField.returnKeyType == .next {
            privateKeyTextView.becomeFirstResponder()
        }else {
            view.endEditing(true)
        }
        return true
    }
    
    func tfDidBeginEditing(_ textField: UITextField) {
        separator2.backgroundColor = WalletColors.blueText.color()
        textField.returnKeyType = importButton.isEnabled ? .done : .next
    }
    
    func tfDidEndEditing(_ textField: UITextField) {
        separator2.backgroundColor = WalletColors.defaultGreyText.color()
    }
    
    func scanDidTapped(_ scan: UIButton) {
        
    }
    
    func bufferDidTapped() {
        
    }
    
    
}

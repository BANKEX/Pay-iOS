//
//  AssetManagementEthAmountTextField.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 05/12/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class AssetManagementEthAmountTextField: UITextField {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard action == #selector(paste(_:)) else {
            return super.canPerformAction(action, withSender: sender)
        }
        
        return false
    }
    
}

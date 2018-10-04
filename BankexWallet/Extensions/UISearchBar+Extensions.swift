//
//  UISearchBar+Extensions.swift
//  BankexWallet
//
//  Created by Vladislav on 26.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit


extension UISearchBar {
    func changeSearchBarColor(color : UIColor) {
        for subView in self.subviews {
            for subSubView in subView.subviews {
                if subSubView.conforms(to:UITextInputTraits.self) {
                    let textField = subSubView as! UITextField
                    textField.backgroundColor = color
                    break
                }
            }
        }
    }
    
    func changeSearchBarTextColor(color:UIColor) {
        for subview in self.subviews {
            for subview in subviews {
                if subview.conforms(to: UITextInputTraits.self) {
                    let textField = subview as! UITextField
                    textField.textColor = color
                    break
                }
            }
        }
    }
}

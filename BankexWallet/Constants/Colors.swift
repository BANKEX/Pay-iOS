//
//  Colors.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/4/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let circleColor = UIColor(hex:"C7CCD4")
    static let mainColor = UIColor(hex: "0DA9FF")
    static let importColor = UIColor(hex: "718093")
    static let separatorColor = UIColor(hex: "718093")
    static let disableColor = UIColor(hex: "E3E6E9")
    static let errorColor = UIColor(hex: "F1361D")
    static let clipboardColor = UIColor(hex:"B8BFC9")
    static let clipboardTextColor = UIColor(hex:"F9FAFC")
    static let bgMainColor = UIColor(hex:"F9FAFC")
    static let createWalletCellColor = UIColor(hex:"9DA6B3")
    static let blackColor = UIColor(hex:"202326")
    static let sendColor = UIColor(hex:"FFB900")
    static let receiveColor = UIColor(hex:"03B221")
    
    struct QRReader {
        static let successColor = UIColor(hex: "03B221")
        static let errorColor = UIColor(hex:"FF3B30")
        static let defaultColor = UIColor(hex:"E0E0E0")
    }
    
    static func setColorForTextViewPlaceholder() -> UIColor  {
        return UIColor.gray.withAlphaComponent(0.5)
    }
}

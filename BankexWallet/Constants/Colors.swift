//
//  Colors.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/4/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

enum WalletColors {
    

    static let mainColor = UIColor(hex: "0DA9FF")
    static let importColor = UIColor(hex: "718093")
    static let separatorColor = UIColor(hex: "718093")
    static let disableColor = UIColor(hex: "E3E6E9")
    static let errorColor = UIColor(hex: "F1361D")
    static let clipboardColor = UIColor(hex:"B8BFC9")
    static let clipboardTextColor = UIColor(hex:"F9FAFC")
    
    case blueText
    case errorRed
    case greySeparator
    case defaultText
    case defaultGreyText
    case disableButtonBackground
    case defaultDarkBlueButton
    case defaultLightBlueButton
    case redText
    case lightGreenText
    case disabledGreyButton
    case headerView
    

    func color() -> UIColor {
        switch self {
        case .blueText:
            return UIColor(red: 35/255, green: 130/255, blue: 255/255, alpha: 1)
        case .errorRed:
            return UIColor(red: 1, green: 0.23, blue: 0.19, alpha: 1)
        case .defaultText:
            return UIColor(red: 32/255, green: 35/255, blue: 38/255, alpha: 1)
        case .defaultGreyText:
            return UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1)
        case .greySeparator:
            return UIColor(red: 188/255, green: 187/255, blue: 193/255, alpha: 1)
        case .disableButtonBackground:
            return UIColor(red: 247/255, green: 249/255, blue: 250/255, alpha: 1)
        case .defaultDarkBlueButton:
            return UIColor(red: 35/255, green: 130/255, blue: 255/255, alpha: 1)
        case .defaultLightBlueButton:
            return UIColor(red: 13/255, green: 169/255, blue: 255/255, alpha: 1)
        case .redText:
            return UIColor(red: 239/255, green: 134/255, blue: 167/255, alpha: 1)
        case .lightGreenText:
            return UIColor(red: 74/255, green: 200/255, blue: 174/255, alpha: 1)
        case .disabledGreyButton:
            return UIColor(red: 0.78, green: 0.8, blue: 0.8, alpha: 1)
        case .headerView:
            return UIColor(red: 251/255, green: 250/255, blue: 255/255, alpha: 1)
        }
    }
    
    static func setColorForTextViewPlaceholder() -> UIColor  {
        return UIColor.gray.withAlphaComponent(0.5)
    }
}

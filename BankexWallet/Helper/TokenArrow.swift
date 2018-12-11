//
//  TokenArrow.swift
//  BankexWallet
//
//  Created by Vladislav on 10/12/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import UIKit

class TokenArrow: UIView {
    
    @IBOutlet private var symbolTokenLabel: UILabel!
    
    public var tokenSymbol:String? {
        get {
            return symbolTokenLabel.text
        }
        set {
            symbolTokenLabel.text = newValue
        }
    }

    
    class func loadFromNib() -> TokenArrow {
        let nib = UINib(nibName: "TokenArrow", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil).first as! TokenArrow
    }
    
    
}



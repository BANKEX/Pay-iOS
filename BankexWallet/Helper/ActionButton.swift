//
//  ActionButton.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 30/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ActionButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = min(frame.size.width, frame.size.height) / 2.0
    }
    
}

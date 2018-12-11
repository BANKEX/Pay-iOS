//
//  UIbutton+Extensions.swift
//  BankexWallet
//
//  Created by Vladislav on 01/10/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import Foundation
import UIKit


extension UIButton {
    func callShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4.0)
        layer.shadowOpacity = 0.2
    }
    
    
}

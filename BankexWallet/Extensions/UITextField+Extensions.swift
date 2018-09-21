//
//  UITextField+Extensions.swift
//  BankexWallet
//
//  Created by Vladislav on 22.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit


extension UITextField {
    var bottomY:CGFloat {
        let originY = self.frame.origin.y
        let value = originY + self.bounds.height
        return value
    }
}

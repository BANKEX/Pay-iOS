//
//  BaseButton.swift
//  BankexWallet
//
//  Created by Vladislav on 17.09.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class BaseButton:UIButton {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let offSet:CGFloat = 15.0
        let newRect = CGRect(x: self.bounds.origin.x - offSet, y: self.bounds.origin.y - offSet, width: self.bounds.size.width + offSet*2, height: self.bounds.size.height + offSet*2)
        return newRect.contains(point)
    }
}

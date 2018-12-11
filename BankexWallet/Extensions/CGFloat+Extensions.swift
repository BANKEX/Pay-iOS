//
//  CGFloat+Extensions.swift
//  BankexWallet
//
//  Created by Vladislav on 17.09.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    
    func next(number:Int) -> CGFloat {
        let inset:CGFloat = 8
        var totalInset:CGFloat
        if number == 1 {
            totalInset = inset*2
        }else {
            totalInset = CGFloat(number+1)*inset
        }
        return self + totalInset
    }
}

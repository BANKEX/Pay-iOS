//
//  String+Extensions.swift
//  BankexWallet
//
//  Created by Vladislav on 17.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func updateToNSSting() -> NSString {
        return NSString(string:self)
    }
    
    func formattedAddrToken(number:Int = 6) -> String {
        let prefix = self.prefix(number)
        let suffix = self.suffix(number)
        return prefix + "..." + suffix
    }
    
    func size(_ font:UIFont) -> CGSize {
        let str = self as NSString
        return str.size(withAttributes: [NSAttributedStringKey.font:font])
    }
    
    func stripZeros() -> String {
        if !self.contains(".") {return self}
        var end = self.index(self.endIndex, offsetBy: -1)
        while self[end] == "0" {
            end = self.index(before: end)
        }
        if self[end] == "." {
            if self[self.index(before: end)] == "0" {
                return "0.0"
            } else {
                return self[...end] + "0"
            }
        }
        return String(self[...end])
    }
}


//
//  String+Extensions.swift
//  BankexWallet
//
//  Created by Vladislav on 17.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

extension String {
    func updateToNSSting() -> NSString {
        return NSString(string:self)
    }
    
    func formattedAddrToken() -> String {
        let prefix = self.prefix(6)
        let suffix = self.suffix(6)
        return prefix + "..." + suffix
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


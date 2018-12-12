//
//  Utils.swift
//  BankexWallet
//
//  Created by Vladislav on 11/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

// MARK: - doesn't print in realese mode
func printDebug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    Swift.print(items[0], separator: separator, terminator: terminator)
    print("************************************************************************************")
    #endif
}

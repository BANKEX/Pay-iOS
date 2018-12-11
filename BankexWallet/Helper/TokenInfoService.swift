//
//  TokenInfoRaws.swift
//  BankexWallet
//
//  Created by Vladislav on 06/10/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import Foundation

enum TokenInfoRaws: Int {
    case address = 0
    case currency = 1
    case decimals = 2
    
    func string() -> String {
        switch self {
        case .address: return NSLocalizedString("Address", comment: "")
        case .currency: return NSLocalizedString("Currency", comment: "")
        case .decimals: return NSLocalizedString("Decimals", comment: "")
        }
    }
}

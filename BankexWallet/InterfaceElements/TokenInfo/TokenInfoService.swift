//
//  TokenInfoService.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 23.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

enum TokenInfoRaws: Int {
    case address = 0
    case currency = 1
    case decimals = 2
    
    func string() -> String {
        switch self {
        case .address: return "Address"
        case .currency: return "Currency"
        case .decimals: return "Decimals"
        }
    }
}

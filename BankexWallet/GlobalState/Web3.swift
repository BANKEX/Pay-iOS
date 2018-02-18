//
//  Web3.swift
//  BankexWallet
//
//  Created by Alexander Vlasov on 29.01.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import web3swift

struct BankexWalletWeb3 {
    
    private static var _web3: web3? = nil
    
    static var web3: web3 {
        get {
            if _web3 == nil {
                _web3 = Web3.InfuraMainnetWeb3()
            }
            return _web3!
        }
    }
}

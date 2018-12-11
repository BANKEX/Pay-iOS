//
//  WalletState.swift
//  BankexWallet
//
//  Created by BANKEX Foundation on 26.01.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import Foundation
import web3swift

struct WalletState {
    static var currentAddress: EthereumAddress? = nil
    static var keystoreManager: AbstractKeystore? = nil
    
}


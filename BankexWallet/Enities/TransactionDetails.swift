//
//  TransactionDetails.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 24/12/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import Foundation
import BigInt

struct TransactionDetails {
    let gasLimit: BigUInt
    let gasPrice: BigUInt
    let blockNumber: BigUInt?
}

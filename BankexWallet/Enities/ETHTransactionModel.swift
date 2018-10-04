//
//  ETHTransactionModel.swift
//  BankexWallet
//
//  Created by Vladislav on 17.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

struct ETHTransactionModel {
    let from: String
    let to: String
    let amount: String
    let date: Date
    let token: ERC20TokenModel
    let key: HDKey
    var isPending = false
}

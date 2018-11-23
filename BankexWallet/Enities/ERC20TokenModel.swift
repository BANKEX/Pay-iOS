//
//  ERC20TokenModel.swift
//  BankexWallet
//
//  Created by Vladislav on 17.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation


struct ERC20TokenModel {
    let name: String
    let address: String
    let decimals: String
    let symbol: String
    let isSelected: Bool
    var isAdded: Bool
    var isSecurity: Bool
    
    init(token: ERC20Token) {
        self.name = token.name ?? ""
        self.address = token.address ?? ""
        self.decimals = token.decimals ?? ""
        self.symbol = token.symbol ?? ""
        self.isSelected = token.isSelected
        self.isAdded = token.isAdded
        self.isSecurity = token.isSecurity
    }
    
    init(name: String,
         address: String,
         decimals: String,
         symbol: String,
         isSelected: Bool,isAdded:Bool = false, isSecurity:Bool) {
        self.name = name
        self.address = address
        self.decimals = decimals
        self.symbol = symbol
        self.isSelected = isSelected
        self.isAdded = isAdded
        self.isSecurity = isSecurity
    }
}

extension ERC20TokenModel: Equatable {
    static func == (lhs: ERC20TokenModel, rhs: ERC20TokenModel) -> Bool {
        return
            lhs.name == rhs.name &&
                lhs.address == rhs.address &&
                lhs.decimals == rhs.decimals &&
                lhs.symbol == rhs.symbol &&
                lhs.isSecurity == rhs.isSecurity
    }
}

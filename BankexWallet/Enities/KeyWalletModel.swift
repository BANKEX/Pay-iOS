//
//  KeyWalletModel.swift
//  BankexWallet
//
//  Created by Vladislav on 17.09.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import Foundation


struct KeyWalletModel {
    let address: String
    let data: Data?
    let isHD: Bool
    let isSelected: Bool
    let name: String
    
    static func from(wallet: KeyWallet?) -> KeyWalletModel? {
        guard let wallet = wallet else {
            return nil
        }
        return KeyWalletModel(address: wallet.address ?? "",
                              data: wallet.data,
                              isHD: wallet.isHD,
                              isSelected: wallet.isSelected,
                              name: wallet.name ?? "")
    }
}

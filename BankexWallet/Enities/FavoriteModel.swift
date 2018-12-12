//
//  FavoriteModel.swift
//  BankexWallet
//
//  Created by Vladislav on 17.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

struct FavoriteModel {
    var name: String
    var address: String
    
    init(_ contact:FavoritesAddress) {
        name = contact.name ?? "..."
        address = contact.address ?? "..."
    }
}

//
//  FavoriteModel.swift
//  BankexWallet
//
//  Created by Vladislav on 17.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

struct FavoriteModel {
    var firstName: String
    var lastname: String
    var address: String
    var lastUsageDate: Date?
    var note:String?
    
    var fullName:String {
        return "\(firstName) \(lastname)"
    }
}

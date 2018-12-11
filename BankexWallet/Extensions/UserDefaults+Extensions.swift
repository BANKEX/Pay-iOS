//
//  UserDefaults+Extensions.swift
//  BankexWallet
//
//  Created by Vladislav on 04/10/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Keys {
        case balance,nameWallet
        func key() -> String {
            switch self {
            case .balance:
                return "Balance"
            case .nameWallet:
                return "Name"
            }
        }
    }
    
    class func createUserDefaults(suiteName:String = "group.PayWidget") -> UserDefaults {
        let userDef = UserDefaults(suiteName: suiteName)
        UserDefaults.standard.synchronize()
        return userDef!
    }
    
    class func saveData(string:String) {
        let userDefauts = createUserDefaults()
        if let _ = Float(string) {
            userDefauts.set(string, forKey: Keys.balance.key())
            return
        }
        userDefauts.set(string, forKey: Keys.nameWallet.key())
    }
    
    
    
    
    
}

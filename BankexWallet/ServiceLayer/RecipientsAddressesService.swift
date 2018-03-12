//
//  RecipientsAddressesService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/11/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol RecipientsAddressesService {
    func store(address: String, with name: String)
    func getAllStoredAddresses() -> [(String, String)]?
    func clearAllSavedAddresses()
    func delete(with name: String)
}

class RecipientsAddressesServiceImplementation: RecipientsAddressesService {
    let keyForStoreRecipientAddresses = "RecipientAddressesKey"
    
    func store(address: String, with name: String) {
        var savedAddresses = UserDefaults.standard.dictionary(forKey: keyForStoreRecipientAddresses)
        if savedAddresses == nil {
            savedAddresses = [name: address]
        }
        else {
            savedAddresses![name] = address
        }
        UserDefaults.standard.set(savedAddresses, forKey: keyForStoreRecipientAddresses)
    }
    
    func getAllStoredAddresses() -> [(String, String)]? {
        guard let savedAddresses = UserDefaults.standard.dictionary(forKey: keyForStoreRecipientAddresses) as? [String: String] else {
            return nil
        }
        
        let sortedAddresses = savedAddresses.map { (key, value) -> (String, String) in
            return (key, value)
        }
        
        return sortedAddresses.sorted { (v1, v2) -> Bool in
            return v1.0 < v2.0
        }
    }
    
    func delete(with name: String) {
        guard var savedAddresses = UserDefaults.standard.dictionary(forKey: keyForStoreRecipientAddresses) as? [String: String] else {
            return
        }
        savedAddresses[name] = nil
        UserDefaults.standard.set(savedAddresses, forKey: keyForStoreRecipientAddresses)
    }
    
    func clearAllSavedAddresses() {
        UserDefaults.standard.set(nil, forKey: keyForStoreRecipientAddresses)
    }

}

//
//  RecipientsAddressesService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/11/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import SugarRecord
protocol RecipientsAddressesService {
    func store(address: String, with name: String)
    func getAllStoredAddresses() -> [(String, String)]?
    func clearAllSavedAddresses()
    func delete(with address: String)
    func contains(address: String) -> Bool
}

class RecipientsAddressesServiceImplementation: RecipientsAddressesService {
    let keyForStoreRecipientAddresses = "RecipientAddressesKey"
    let db = DBStorage.db
    func contains(address: String) -> Bool {
        let addresses = getAllStoredAddresses()
        let contains = addresses?.contains(where: { (_, localAddress) -> Bool in
            return address == localAddress
        })
        return contains ?? false
    }
    
    func store(address: String, with name: String) {
        do {
            try db.operation({ (context, save) in
                
                if let _ = try? context.fetch(FetchRequest<RecepientAddress>().filtered(with: NSPredicate(format: "name == %@", name))).first {
                    //error
                } else {
                    let recepientAddress: RecepientAddress = try context.new()
                    recepientAddress.name = name
                    recepientAddress.address = address
                    
                    try context.insert(recepientAddress)
                }
                save()
                
            })
        } catch {
           print(error)
        }
        
    }
    
    func getAllStoredAddresses() -> [(String, String)]? {
        let request = FetchRequest<RecepientAddress>().sorted(with: "name", ascending: true)
        var sortedAddresses = [(String, String)]()
        do {
            try DBStorage.db.operation { (context, _) in
                guard let addresses = try? context.fetch(request) else { return }
                sortedAddresses = addresses.map({ (recepientAddress) -> (String, String) in
                    guard let name = recepientAddress.name else { return ("", "") }
                    guard let address = recepientAddress.address else { return ("", "") }
                    return (name, address)
                })
            }
            
            return sortedAddresses
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func delete(with address: String) {
        guard var savedAddresses = UserDefaults.standard.dictionary(forKey: keyForStoreRecipientAddresses) as? [String: String],
            let (name, _) = savedAddresses.first(where: { (_, localAddress) -> Bool in
                return address == localAddress
            }) else {
            return
        }
        
        savedAddresses[name] = nil
        UserDefaults.standard.set(savedAddresses, forKey: keyForStoreRecipientAddresses)
    }
    
    func clearAllSavedAddresses() {
        UserDefaults.standard.set(nil, forKey: keyForStoreRecipientAddresses)
    }

}

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
                
                if let _ = try context.fetch(FetchRequest<RecepientAddress>().filtered(with: NSPredicate(format: "name == %@", name))).first {
                    print("Error, given name already exists in the database")
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
        
        do {
            let addresses = try db.fetch(request)
            let sortedAddresses = addresses.map({ (recepientAddress) -> (String, String) in
                guard let name = recepientAddress.name else { return ("", "") }
                guard let address = recepientAddress.address else { return ("", "") }
                return (name, address)
            })
            return sortedAddresses
        } catch {
            print(error)
        }
        return nil
    }
    
    func delete(with address: String) {
        do {
            try db.operation { (context, save)  in
                let fav = try context.fetch(FetchRequest<RecepientAddress>().filtered(with: NSPredicate(format: "address == %@", address))).first
                if let fav = fav {
                    try context.remove([fav])
                    save()
                }
            }
        } catch {
            print(error)
        }
    }
    
    func clearAllSavedAddresses() {
        do {
            try db.operation { (context, save) in
                let fav = try context.fetch(FetchRequest<RecepientAddress>())
                if !fav.isEmpty {
                    try context.remove(fav)
                    save()
                }
            }
        } catch {
            print(error)
        }
    }
    
    func update(address: String, with name: String) {
        do {
            try db.operation { (context, save) in
                if let data = try? context.fetch(FetchRequest<RecepientAddress>().filtered(with: NSPredicate(format: "name == %@", name))).first {
                    data?.address = address
                    save()
                }
            }
        } catch {
            print(error)
        }
    }

}

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
    func store(address: String, with name: String, completionHandler: @escaping (Error?) -> Void)
    func getAllStoredAddresses() -> [FavoriteModel]?
    func clearAllSavedAddresses()
    func delete(with address: String, completionHandler: (() -> Void)?)
    func contains(address: String) -> Bool
}

class RecipientsAddressesServiceImplementation: RecipientsAddressesService {
    
    let db = DBStorage.db
    func contains(address: String) -> Bool {
        do {
            if let _ = try db.fetch(FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "address == %@", address))).first {
                return true
            } else {
                return false
            }
        } catch {
            
        }
        return false
    }
    
    func store(address: String, with name: String, completionHandler: @escaping (Error?) -> Void) {
        do {
            try db.operation({ (context, save) in
                
                if let _ = try context.fetch(FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "name == %@", name))).first {
                    DispatchQueue.main.async {
                        let error = NameError(errorDescription: "Name already exists in the database")
                        completionHandler(error)
                    }
                    
                } else {
                    let recepientAddress: FavoritesAddress = try context.new()
                    recepientAddress.name = name
                    recepientAddress.address = address
                    
                    try context.insert(recepientAddress)
                    save()
                    DispatchQueue.main.async {
                        completionHandler(nil)
                    }
                }
                
                
            })
        } catch {
           completionHandler(error)
        }
        
    }
    
    func getAllStoredAddresses() -> [FavoriteModel]? {
        
        let request = FetchRequest<FavoritesAddress>().sorted(with: "name", ascending: true)
        
        do {
            let addresses = try db.fetch(request)
            let sortedAddresses = addresses.map({ (recepientAddress) -> FavoriteModel in
                let name = recepientAddress.name  ?? ""
                let address = recepientAddress.address ?? ""
                return FavoriteModel(name: name, address: address, lastUsageDate: nil)
            })
            
            return sortedAddresses
        } catch {
            print(error)
        }
        return nil
    }
    
    func delete(with address: String, completionHandler: (() -> Void)?) {
        do {
            
            try db.operation { (context, save)  in
                if let fav = try context.fetch(FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "address == %@", address))).first {
                    try context.remove(fav)
                    save()
                    DispatchQueue.main.async {
                        completionHandler?()
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler?()
                    }
                }
            }
        } catch {
            print(error)
            
        }
    }
    
    func clearAllSavedAddresses() {
        do {
            try db.operation { (context, save) in
                let fav = try context.fetch(FetchRequest<FavoritesAddress>())
                try context.remove(fav)
                save()
            }
        } catch {
            print(error)
        }
    }
    
    func updateAddress(newAddress address: String, byName name: String) {
        do {
            try db.operation { (context, save) in
                if let data = try? context.fetch(FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "name == %@", name))).first {
                    data?.address = address
                    save()
                }
            }
        } catch {
            print(error)
        }
    }
    
    func updateName(newName name: String, byAddress address: String) {
        do {
            try db.operation { (context, save) in
                if let data = try? context.fetch(FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "address == %@", address))).first {
                    data?.name = address
                    save()
                }
            }
        } catch {
            print(error)
        }
    }

}

struct FavoriteModel {
    var name: String
    var address: String
    var lastUsageDate: Date?
}

struct NameError: LocalizedError {
    public let errorDescription: String?
}

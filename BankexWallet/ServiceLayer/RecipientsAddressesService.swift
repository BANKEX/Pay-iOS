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
    func store(address: String, with firstName: String,lastName:String, isEditing: Bool, completionHandler: @escaping (Error?) -> Void)
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
    
    func store(address: String, with firstName: String, lastName:String, isEditing editing: Bool, completionHandler: @escaping (Error?) -> Void) {
        do {
            try db.operation({ (context, save) in
                
                if let contact = try context.fetch(FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "address == %@", address))).first {
                    if editing {
                        contact.address = address
                        contact.firstName = firstName
                        contact.lastName = lastName
                        save()
                        DispatchQueue.main.async {
                            completionHandler(nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            let error = NameError(errorDescription: "Address already exists in the database")
                            completionHandler(error)
                        }
                    }
                } else if let contact = try context.fetch(FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "firstName == %@", firstName))).first {
                    if editing {
                        contact.address = address
                        contact.firstName = firstName
                        save()
                        DispatchQueue.main.async {
                            completionHandler(nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            let error = NameError(errorDescription: "Name already exists in the database")
                            completionHandler(error)
                        }
                    }
                } else {
                    let recepientAddress: FavoritesAddress = try context.new()
                    recepientAddress.firstName = firstName
                    recepientAddress.lastName = lastName
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
        
        let request = FetchRequest<FavoritesAddress>().sorted(with: "lastName", ascending: true)
        
        do {
            let addresses = try db.fetch(request)
            let sortedAddresses = addresses.map({ (recepientAddress) -> FavoriteModel in
                let fName = recepientAddress.firstName  ?? ""
                let lName = recepientAddress.lastName ?? ""
                let address = recepientAddress.address ?? ""
                return FavoriteModel(firstName: fName, lastname: lName, address: address, lastUsageDate: nil)
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
    
    func updateAddressBylastName(newAddress address: String, byName name: String) {
        do {
            try db.operation { (context, save) in
                if let data = try? context.fetch(FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "lastName == %@", name))).first {
                    data?.address = address
                    save()
                }
            }
        } catch {
            print(error)
        }
    }
    
    func updateFirstName(newName name: String, byAddress address: String) {
        do {
            try db.operation { (context, save) in
                if let data = try? context.fetch(FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "address == %@", address))).first {
                    data?.firstName = name
                    save()
                }
            }
        } catch {
            print(error)
        }
    }
    
    func updateLastName(newName name: String, byAddress address: String) {
        do {
            try db.operation { (context, save) in
                if let data = try? context.fetch(FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "address == %@", address))).first {
                    data?.lastName = name
                    save()
                }
            }
        } catch {
            print(error)
        }
    }

}

struct FavoriteModel {
    var firstName: String
    var lastname: String
    var address: String
    var lastUsageDate: Date?
}

struct NameError: LocalizedError {
    public let errorDescription: String?
}

//
//  RecipientsAddressesService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/11/2561 BE.
//  Copyright © 2561 BANKEX Foundation. All rights reserved.
//

import UIKit
import SugarRecord



protocol ContactServiceProtocol {
    func saveContact(address: String, with name:String, onComplition: @escaping (Error?) -> Void)
    func listContacts(onCompition:@escaping([FavoriteModel]?)->())
    func removeAll()
    func delete(with address: String, completionHandler:@escaping (Bool) -> Void)
    func contains(address: String) -> Bool
}


class ContactService: ContactServiceProtocol {
    
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
    
    func saveContact(address: String, with name:String, onComplition: @escaping (Error?) -> Void) {
        do {
            try db.operation({ (context, save) in
                if let _ = try context.fetch(FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "address == %@", address))).first {
                    DispatchQueue.main.async {
                        let error = NameError(errorDescription: "Address already exists in the database")
                        onComplition(error)
                    }
                }else if let _ = try context.fetch(FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "name == %@",name))).first {
                    DispatchQueue.main.async {
                        let error = NameError(errorDescription: "Name already exists in the database")
                        onComplition(error)
                    }
                }else {
                    let contact:FavoritesAddress = try context.new()
                    contact.name = name
                    contact.address = address
                    try context.insert(contact)
                    save()
                    DispatchQueue.main.async {
                        onComplition(nil)
                    }
                }
            })
        } catch let error {
            onComplition(error)
            printDebug("Error create contact:\(error)")
        }
    }
    
    func listContacts(onCompition:@escaping([FavoriteModel]?)->()) {
        var contacts = [FavoriteModel]()
        let request = FetchRequest<FavoritesAddress>().sorted(with: "name", ascending: true)
        do {
            let initialContacts = try db.fetch(request)
            initialContacts.forEach { contact in
                contacts.append(FavoriteModel(contact))
            }
            DispatchQueue.main.async {
               onCompition(contacts)
            }
        } catch {
            printDebug("Error get list contacts:\(error)")
        }
    }
    
    func contactByAddress(_ address:String, onComplition:@escaping (FavoriteModel?)->Void) {
        let request = FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "address == %@", address))
        do {
            guard let contact = try db.fetch(request).first else {
                DispatchQueue.main.async {
                    onComplition(nil)
                }
                return
            }
            let unwrapContact = FavoriteModel(contact)
            DispatchQueue.main.async {
                onComplition(unwrapContact)
            }
        } catch {
            DispatchQueue.main.async {
                onComplition(nil)
                printDebug("Error get contact by address:\(error)")
            }
        }
    }
    func contactByName(_ name:String, onComplition:@escaping (FavoriteModel?)->Void) {
        let request = FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "name == %@", name))
        do {
            guard let contact = try db.fetch(request).first else {
                DispatchQueue.main.async {
                    onComplition(nil)
                }
                return
            }
            let unwrapContact = FavoriteModel(contact)
            DispatchQueue.main.async {
                onComplition(unwrapContact)
            }
        } catch {
            DispatchQueue.main.async {
                onComplition(nil)
                printDebug("Error get contact by name:\(error)")
            }
        }
    }
    
    func delete(with address: String, completionHandler:@escaping (Bool) -> Void) {
        let request = FetchRequest<FavoritesAddress>().filtered(with: NSPredicate(format: "address == %@", address))
        do {
            try db.operation({ (context, save) in
                guard let contact = try context.fetch(request).first else {
                    completionHandler(false)
                    return
                }
                try context.remove(contact)
                save()
                DispatchQueue.main.async {
                    completionHandler(true)
                }
            })
        }catch let error {
           completionHandler(false)
            printDebug("Error remove contact:\(error)")
        }
    }
    
    
    func removeAll() {
        do {
            try db.operation { (context, save) in
                let contacts = try context.fetch(FetchRequest<FavoritesAddress>())
                try context.remove(contacts)
                save()
            }
        } catch {
            printDebug("Error remove all contacts:\(error)")
        }
    }
    
    func updateAddress(newAddress:String,_ name:String,onComplition:@escaping (Bool)->()) {
        do {
            let request = FetchRequest<FavoritesAddress>().filtered(with:NSPredicate(format: "name == %@", name))
            try db.operation({ (context, save) in
                guard let contact = try context.fetch(request).first else {
                    DispatchQueue.main.async {
                        onComplition(false)
                    }
                    return
                }
                contact.address = newAddress
                save()
                DispatchQueue.main.async {
                    onComplition(true)
                }
            })
        }catch {
            printDebug("Error update contact by name:\(error)")
        }
    }
    
    func updateName(newName:String,_ address:String, onComplition:@escaping (Bool)->()) {
        do {
            let request = FetchRequest<FavoritesAddress>().filtered(with:NSPredicate(format: "address == %@", address))
            try db.operation({ (context, save) in
                guard let contact = try context.fetch(request).first else {
                    DispatchQueue.main.async {
                        onComplition(false)
                    }
                    return
                }
                contact.name = newName
                save()
                DispatchQueue.main.async {
                    onComplition(true)
                }
            })
        }catch {
            printDebug("Error update contact by address:\(error)")
        }
    }

}



struct NameError: LocalizedError {
    public let errorDescription: String?
}

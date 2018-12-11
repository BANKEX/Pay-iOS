//
//  KeysService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/11/2561 BE.
//  Copyright © 2561 BANKEX Foundation. All rights reserved.
//

import UIKit
import web3swift
import SugarRecord




enum WalletCreationError: Error {
    case creationError
}

enum WalletDeletingError: Error {
    case deletingError
}

protocol SingleKeyService: GlobalWalletsService {
    
    func createNewSingleAddressWallet(with name: String?,
                                      password: String?,
                                      completion: @escaping (Error?)-> Void)
    func createNewSingleAddressWallet(with name: String?,
                                      fromText privateKey: String,
                                      password: String?,
                                      completion: @escaping (Error?)-> Void)
    func fullListOfPublicAddresses() -> [String]?
}

class SingleKeyServiceImplementation: SingleKeyService {
    
    private var selectedLocalWallet: KeyWalletModel?
    
    func selectedWallet() -> KeyWalletModel? {
        return selectedLocalWallet
    }
    
    let userDefaultsKeyForSelectedAddress = "SelectedAddress"
    
    let defaultPassword: String
    
    init(defaultPassword: String = "BANKEXFOUNDATION") {
        self.defaultPassword = defaultPassword
        selectedLocalWallet = selectedLocalWallet ?? selectedWalletFromDB()
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeWallet.notificationName(), object: nil, queue: nil) { (_) in
            self.selectedLocalWallet = self.selectedWalletFromDB()
        }
    }
    
    func updateSelectedWallet() {
        selectedLocalWallet = selectedWalletFromDB()
    }
    
    
    func fullListOfPublicAddresses() -> [String]? {        
        guard let allKeys = try? db.fetch(FetchRequest<KeyWallet>().filtered(with: NSPredicate(format: "isHD == %@", NSNumber(value: false)))) else {
            return nil
        }
        return allKeys.compactMap({ (wallet) -> String in
            return wallet.address ?? ""
        })
    }
    
    func updateWalletName(name:String, address:String,completion:@escaping (Error?)->Void) {
        do {
            try db.operation({ (context, save) in
                if let data = try? context.fetch(FetchRequest<KeyWallet>().filtered(with: NSPredicate(format: "address == %@", address))).first {
                    data?.name = name
                    save()
                    completion(nil)
                }else {
                    completion(NSError())
                }
            })
        }catch let error {
            completion(error)
        }
    }
    
    
    func createNewSingleAddressWallet(with name: String?,
                                      password: String? = nil,
                                      completion: @escaping (Error?)-> Void) {
        let usingPassword = password ?? defaultPassword
        guard let newWallet = try? EthereumKeystoreV3(password: usingPassword) else {
            completion(WalletCreationError.creationError)
            return
        }
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {
            completion(WalletCreationError.creationError)
            return
        }
        guard let keydata = try? JSONEncoder().encode(wallet.keystoreParams) else {
            completion(WalletCreationError.creationError)
            return
        }
        guard let address = newWallet?.addresses?.first?.address else {
            completion(WalletCreationError.creationError)
            return
        }
        save(with: name, keyData: keydata, for: address, completion: completion)
    }
    
    func createNewSingleAddressWallet(with name: String?,
                                      fromText privateKey: String,
                                      password: String?,
                                      completion: @escaping (Error?)-> Void) {
        let text = privateKey.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard let data = Data.fromHex(text) else {
            completion(WalletCreationError.creationError)
            return
        }
        guard let newWallet = try? EthereumKeystoreV3(privateKey: data, password: password ?? defaultPassword) else {
            completion(WalletCreationError.creationError)
            return
        }
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {
            completion(WalletCreationError.creationError)
            return
        }
        guard let keydata = try? JSONEncoder().encode(wallet.keystoreParams) else {
            completion(WalletCreationError.creationError)
            return
        }
        guard let address = newWallet?.addresses?.first?.address else {
            completion(WalletCreationError.creationError)
            return
        }
        DispatchQueue.global().async {
            self.save(with: name, keyData: keydata, for: address, completion: completion)
        }
    }
    
    
    // MARK: Private Part
    let db = DBStorage.db
    private func save(with name: String?,
                      keyData: Data,
                      for address: String,
                      completion: @escaping (Error?)-> Void) {
        do {
            try db.operation({ (context, save) in
                let newWallet: KeyWallet = try context.new()
                newWallet.name = name
                newWallet.address = address
                newWallet.isHD = false
                newWallet.isSelected = false
                newWallet.data = keyData
                try context.insert(newWallet)
                save()
                self.updateSelected(address: address)
                DispatchQueue.main.async {
                    completion(nil)
                }
            })
        }
        catch {
            DispatchQueue.main.async {
                completion(WalletCreationError.creationError)
            }
        }
    }
    
    func delete(completion: @escaping (Error?)-> Void) {
        do {
            try db.operation({ (context, save) in
                let wallets: [KeyWallet?] = try context.request(KeyWallet.self).fetch()
                for wallet in wallets {
                    try context.remove([wallet!])
                }
                save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            })
        }
        catch {
            DispatchQueue.main.async {
                completion(WalletDeletingError.deletingError)
            }
        }
    }
}

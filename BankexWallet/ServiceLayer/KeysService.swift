//
//  KeysService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/11/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift
import SugarRecord

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

    let userDefaultsKeyForSelectedAddress = "SelectedAddress"
    
    let defaultPassword: String
    
    init(defaultPassword: String = "BANKEXFOUNDATION") {
        self.defaultPassword = defaultPassword
    }
    
    
    func fullListOfPublicAddresses() -> [String]? {        
        guard let allKeys = try? db.fetch(FetchRequest<KeyWallet>().filtered(with: NSPredicate(format: "isHD == %@", NSNumber(value: false)))) else {
            return nil
        }
        return allKeys.flatMap({ (wallet) -> String in
            return wallet.address ?? ""
        })
    }
    
    func createNewSingleAddressWallet(with name: String?,
                                      password: String? = nil,
                                      completion: @escaping (Error?)-> Void) {
        let usingPassword = password ?? defaultPassword
        guard let newWallet = try? EthereumKeystoreV3(password: usingPassword) else {return}
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {return}
        guard let keydata = try? JSONEncoder().encode(wallet.keystoreParams) else {return}
        guard let address = newWallet?.addresses?.first?.address else {return}
        save(with: name, keyData: keydata, for: address, completion: completion)
    }
    
    func createNewSingleAddressWallet(with name: String?,
                                      fromText privateKey: String,
                                      password: String?,
                                      completion: @escaping (Error?)-> Void) {
        let text = privateKey.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard let data = Data.fromHex(text) else {return}
        guard let newWallet = try? EthereumKeystoreV3(privateKey: data, password: password ?? defaultPassword) else {return}
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {return}
        guard let keydata = try? JSONEncoder().encode(wallet.keystoreParams) else {return}
        guard let address = newWallet?.addresses?.first?.address else {return}
        save(with: name, keyData: keydata, for: address, completion: completion)
    }
    
    
    // MARK: Private Part
    let db = DBStorage.db
    
    private func save(with name: String?,
                      keyData: Data,
                      for address: String,
                      completion: @escaping (Error?)-> Void) {
        
        db.backgroundOperation({ (context, save) in
            do {
                let newWallet: KeyWallet = try context.new()
                newWallet.name = name
                newWallet.address = address
                newWallet.isHD = false
                newWallet.isSelected = true
                newWallet.data = keyData
                try context.insert(newWallet)
                save()
            }
            catch {
                
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
}

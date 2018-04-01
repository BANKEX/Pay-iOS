//
//  HDWalletService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/11/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import Foundation
import web3swift
import SugarRecord

struct HDKey {
    let name: String?
    let address: String
}

enum HDWalletCreationError: Error {
    case creationError
}

/*
    Service for work with HD key wallets
 */
protocol HDWalletService {
    
    func generateMnemonics(bitsOfEntropy: Int) -> String
    func generateMnemonics() -> String
    
    func createNewHDWallet(with name: String?,
                           mnemonics: String,
                           mnemonicsPassword: String,
                           walletPassword: String,
                           completion: @escaping (String?, Error?) -> Void)
    
    func generateChildNode(forKey: HDKey,
                           password: String,
                           completion: @escaping (String?, Error?) -> Void)
    
    
    func fullHDKeysList() -> [HDKey]?
}

extension HDWalletService {
    
    func generateMnemonics() -> String {
        return generateMnemonics(bitsOfEntropy: 128)
    }
    
}

/*
 Need to remember, that under the hood might be multiple wallets with multiple keys in each
 */
class HDWalletServiceImplementation: HDWalletService {
    
    func fullHDKeysList() -> [HDKey]? {
        guard let allKeys = try? db.fetch(FetchRequest<KeyWallet>().filtered(with: NSPredicate(format: "isHD == %@", NSNumber(value: true)))) else {
            return nil
        }
        return allKeys.map({ (wallet) -> HDKey in
            return HDKey(name: wallet.name, address: wallet.address ?? "")
        })
    }
    
    
    func generateMnemonics(bitsOfEntropy: Int) -> String {
        guard let mnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy),
            let unwrapped = mnemonics else {
            return ""
        }
        return unwrapped
    }
    
    // After this method should be created new wallet with only one root address
    func createNewHDWallet(with name: String?,
                           mnemonics: String,
                           mnemonicsPassword: String,
                           walletPassword: String,
                           completion: @escaping (String?, Error?) -> Void) {
        // TODO: smth strange is here with throwing
        do {
            
            guard let keystore = try? BIP32Keystore(mnemonics: mnemonics,
                                                    password: walletPassword,
                                                    mnemonicsPassword: mnemonicsPassword,
                                                    language: .english),
                let wallet = keystore else {
                    throw HDWalletCreationError.creationError
            }
            saveWalletInfo(name: name, wallet: wallet, completion: completion)
            
        }
        catch (let error) {
            completion(nil, error)
        }
    }
    

    func generateChildNode(forKey: HDKey,
                           password: String,
                           completion: @escaping (String?, Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.db.operation({ (context, save) in
                    guard let key = try context.fetch(FetchRequest<KeyWallet>().filtered(with: "address", equalTo: forKey.address)).first, let data = key.data else {
                        DispatchQueue.main.async {
                            completion(nil, nil)
                        }
                        return
                    }
                    
                    let wallet = BIP32Keystore(data)
                    try wallet?.createNewChildAccount(password: password)
                    let addresses = wallet?.addresses
                    print("\(addresses)")
                })
            }
            catch {
                DispatchQueue.main.async {
                    completion(nil, nil)
                }
            }
            
        }
    }
    
    
    // MARK: Private Part
    let db = DBStorage.db
    
//    private func
    
    // This is saving of parent HD wallet
    private func saveWalletInfo(name: String?,
                                wallet: BIP32Keystore,
                                completion: @escaping (String?, Error?) -> Void) {
        
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        try self.db.operation { (context, save) in
                            guard let keydata = try? JSONEncoder().encode(wallet.keystoreParams) else {
                                throw HDWalletCreationError.creationError
                            }
                            let newWallet: KeyWallet = try context.new()
                            newWallet.name = name
                            newWallet.address = wallet.addresses?.first?.address
                            newWallet.isHD = true
                            newWallet.isSelected = true
                            newWallet.data = keydata
                            try context.insert(newWallet)
                            save()
                            DispatchQueue.main.async {
                                completion(wallet.addresses?.first?.address, nil)
                            }
                        }
                    } catch {
                        //TODO: There was an error in the operation
                    }
                }
        
        
//        guard wallet.addresses?.count == 1 else {return}
//        guard let keydata = try? JSONEncoder().encode(wallet.keystoreParams) else {return}
//        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        guard let address = wallet.addresses?.first?.address else {return}
//        let path = userDir + BankexWalletConstants.BIP32KeystoreStoragePath
//        let fileManager = FileManager.default
//        var isDir : ObjCBool = false
//        var exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
//        if (!exists && !isDir.boolValue){
//            try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
//            exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
//        }
//        if (!isDir.boolValue) {
//            return
//        }
//        FileManager.default.createFile(atPath: path + "/" + address + ".json", contents: keydata, attributes: nil)

    }
}

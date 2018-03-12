//
//  KeysService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/11/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

//TODO: Part of these calls should throw
protocol SingleKeyService {
    
    func createNewSingleAddressWallet(withPassword password: String?)
    func createNewSingleAddressWallet(fromText privateKey: String)
    func fullListOfPublicAddresses() -> [String]?
    func preferredSingleAddress() -> String?
    func updatePreferred(address: String)
    func delete(address: String)
    func keystoreManager() -> KeystoreManager?
}

//TODO: Add here more magic for default things
class SingleKeyServiceImplementation: SingleKeyService {
    
    func keystoreManager() -> KeystoreManager? {
        return KeystoreManager.managerForPath(defaultKeystorePath)
    }
    
    let userDefaultsKeyForSelectedAddress = "SelectedAddress"
    
    let pathForKeys: String
    let defaultPassword: String
    let defaultKeystorePath = "/keystore"
    
    init(pathToStoreKeys: String = "/keystore", defaultPassword: String = "BANKEXFOUNDATION") {
        self.pathForKeys = pathToStoreKeys
        self.defaultPassword = defaultPassword
    }
    
    func preferredSingleAddress() -> String? {
        guard let selectedAddress = UserDefaults.standard.string(forKey: userDefaultsKeyForSelectedAddress) else {
            if let address = fullListOfPublicAddresses()?.first {
                return address
            }
            return nil
        }
        return selectedAddress
    }
    
    func updatePreferred(address: String) {
        UserDefaults.standard.set(address, forKey: userDefaultsKeyForSelectedAddress)
    }
    
    func fullListOfSingleEthereumAddresses() -> [EthereumAddress]? {
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keystoreManager = KeystoreManager.managerForPath(userDir + pathForKeys)
        
        return keystoreManager?.addresses
    }
    
    func fullListOfPublicAddresses() -> [String]? {
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keystoreManager = KeystoreManager.managerForPath(userDir + pathForKeys)
        
        return keystoreManager?.addresses?.flatMap{ (ethAddress) -> String in
            return ethAddress.address
        }
    }
    
    func createNewSingleAddressWallet(withPassword password: String? = nil) {
        let usingPassword = password ?? defaultPassword
        guard let newWallet = try? EthereumKeystoreV3(password: usingPassword) else {return}
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {return}
        guard let keydata = try? JSONEncoder().encode(wallet.keystoreParams) else {return}
        guard let address = newWallet?.addresses?.first?.address else {return}
        save(keyData: keydata, for: address)
    }
    
    func createNewSingleAddressWallet(fromText privateKey: String) {
        let text = privateKey.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard let data = Data.fromHex(text) else {return}
        guard let newWallet = try? EthereumKeystoreV3(privateKey:data) else {return}
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {return}
        guard let keydata = try? JSONEncoder().encode(wallet.keystoreParams) else {return}
        guard let address = newWallet?.addresses?.first?.address else {return}
        save(keyData: keydata, for: address)
    }
    
    private func save(keyData: Data, for address: String) {
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = userDir + pathForKeys
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        var exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        if (!exists && !isDir.boolValue){
            try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        }
        if (!isDir.boolValue) {
            return
        }
        fileManager.createFile(atPath: path + "/" + address + ".json", contents: keyData, attributes: nil)
    }
    
    func delete(address: String) {
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = userDir + pathForKeys
        let fileManager = FileManager.default
        try! fileManager.removeItem(atPath: path + "/" + address + ".json")
    }
    
    func clearAllWallets() {
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = userDir + pathForKeys
        let fileManager = FileManager.default
        try! fileManager.removeItem(atPath: path)
    }
}

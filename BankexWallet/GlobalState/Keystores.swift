//
//  Keystores.swift
//  BankexWallet
//
//  Created by Alexander Vlasov on 26.01.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import web3swift

struct BankexWalletKeystores {
    
    private static var _EthereumKeystoresManager: KeystoreManager? = nil
    private static var _BIP32KeystoresManager: KeystoreManager? = nil
    
    static var EthereumKeystoresManager:KeystoreManager {
        get {
            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            guard let keystoreManager = KeystoreManager.managerForPath(userDir + BankexWalletConstants.KeystoreStoragePath) else {fatalError("Can't create keystore")}
            return keystoreManager
        }
    }
    
    static var BIP32KeystoresManager:KeystoreManager {
        get {
            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            guard let keystoreManager = KeystoreManager.managerForPath(userDir + BankexWalletConstants.BIP32KeystoreStoragePath, scanForHDwallets: true) else {fatalError("Can't create keystore")}
            return keystoreManager
        }
    }
}

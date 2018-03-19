//
//  UtilTransactionsService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/12/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift
import BigInt

enum UtilTransactionsErrors: Error {
    case invalidAddress
    case transactionError
}

protocol UtilTransactionsService {
    
    func getBalance(for token: String,
                    address: String,
                    completion: @escaping (SendEthResult<BigUInt>)->Void)
    func name(for token: String,completion: @escaping (SendEthResult<String>) -> Void)
    func symbol(for token: String,completion: @escaping (SendEthResult<String>) -> Void)
    func decimals(for token: String,completion: @escaping (SendEthResult<BigUInt>) -> Void)
    
}

class UtilTransactionsServiceImplementation: UtilTransactionsService {
    
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    
    func name(for token: String, completion: @escaping (SendEthResult<String>) -> Void) {
        completion(SendEthResult.Success("Ether"))
    }
    
    func symbol(for token: String, completion: @escaping (SendEthResult<String>) -> Void) {
        completion(SendEthResult.Success("Eth"))
    }
    
    func decimals(for token: String, completion: @escaping (SendEthResult<BigUInt>) -> Void) {
        completion(SendEthResult.Success(BigUInt(18)))
    }
    
    
    func getBalance(for token: String,
                    address: String,
                    completion: @escaping (SendEthResult<BigUInt>)->Void) {
        DispatchQueue.global().async {
            let web3 = WalletWeb3Factory.web3
            let ethAddress = EthereumAddress(address)
            guard ethAddress.isValid else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(UtilTransactionsErrors.invalidAddress))
                }
                return
            }
            let result = web3.eth.getBalance(address: ethAddress)
            guard result.error == nil,
                let resultValue = result.value else {
                    DispatchQueue.main.async {
                        completion(SendEthResult.Error(UtilTransactionsErrors.transactionError))
                    }
                    return
            }
            DispatchQueue.main.async {
                completion(SendEthResult.Success(resultValue))
            }
        }
    }
    

}

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
import web3swift
import SugarRecord

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
        completion(SendEthResult.Success(self.localGetBalance(for: token, address: address)))
        DispatchQueue.global().async {
            let web3 = WalletWeb3Factory.web3()
            
            guard let ethAddress = EthereumAddress(address) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(UtilTransactionsErrors.invalidAddress))
                }
                return
            }
            let result = web3.eth.getBalance(address: ethAddress)
            guard result.error == nil,
                let resultValue = result.value else {
                    DispatchQueue.main.async {
                        completion(SendEthResult.Success(self.localGetBalance(for: token, address: address)))
                    }
                    return
            }
            DispatchQueue.main.async {
                self.update(balance: resultValue, token: token, address: address)
                completion(SendEthResult.Success(resultValue))
            }
        }
    }
    
    fileprivate let networkUrl = NetworksServiceImplementation().preferredNetwork().fullNetworkUrl.absoluteString
    fileprivate func localGetBalance(for token: String, address: String) -> BigUInt {
        let balances = !token.isEmpty ? try? DBStorage.db.fetch(FetchRequest<TokenBalance>().filtered(with: NSPredicate(format: "token.address == %@ && wallet.address == %@  && networkUrl == %@", token, address, networkUrl))) :
            try? DBStorage.db.fetch(FetchRequest<TokenBalance>().filtered(with: NSPredicate(format: "token == nil && wallet.address == %@ && networkUrl == %@", address, networkUrl)))
        
        guard let balance = balances?.first else {
            return BigUInt(0)
        }
        return BigUInt(balance.balance ?? "0") ?? BigUInt(0)
    }

    fileprivate func update(balance: BigUInt, token: String, address: String) {
        do {
            try DBStorage.db.operation({ (context, save) in
                
                if let storedBalance = try? context.fetch(FetchRequest<TokenBalance>().filtered(with: NSPredicate(format: "token == nil && wallet.address == %@  && networkUrl == %@", address, self.networkUrl))).first, storedBalance != nil {
                    //We already have the data only need to update
                    storedBalance?.balance = balance.description
                } else {
                    let tokenBalance: TokenBalance = try context.new()
                    tokenBalance.balance = balance.description
                    if !token.isEmpty,
                        let fulltoken =  try? context.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "address == %@", token))).first {
                        tokenBalance.token = fulltoken
                    }
                    if let wallet = try? context.fetch(FetchRequest<KeyWallet>().filtered(with: NSPredicate(format: "address == %@", address))).first {
                        tokenBalance.wallet = wallet
                    }
                    tokenBalance.networkUrl = self.networkUrl
                    try context.insert(tokenBalance)
                }
                save()
                
            })
        } catch {
            
        }
    }
}

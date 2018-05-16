//
//  CustomTokenUtilsService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 3/14/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import BigInt
import web3swift
import SugarRecord

enum CustomTokenError: Error {
    case wrongBalanceError
    case badNameError
    case badSymbolError
    case undefinedError
}


class CustomTokenUtilsServiceImplementation: UtilTransactionsService {
    
    func name(for token: String, completion: @escaping (SendEthResult<String>) -> Void) {
//        DispatchQueue.global(qos: .userInitiated).async {
            let contract = self.contract(for: token)
        if let transaction = contract?.method("name", parameters: [AnyObject](), options: self.defaultOptions()) {
        
            transaction.call(options: self.defaultOptions(), onBlock: "latest", callback: { (result) in
                DispatchQueue.main.async {
                    if let name = result.value?["0"] as? String, !name.isEmpty {
                        completion(SendEthResult.Success(name))
                    }
                    else {
                        completion(SendEthResult.Error(CustomTokenError.badNameError))
                    }
                }
            })
        } else {
            completion(SendEthResult.Error(CustomTokenError.badNameError))
        }
    }
    
    func symbol(for token: String, completion: @escaping (SendEthResult<String>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let contract = self.contract(for: token)
            let transaction = contract?.method("symbol", parameters: [AnyObject](), options: self.defaultOptions())
            let bkxBalance = transaction?.call(options: self.defaultOptions())
            DispatchQueue.main.async {
                if let symbol = bkxBalance?.value?["0"] as? String, !symbol.isEmpty  {
                    completion(SendEthResult.Success(symbol))
                }
                else {
                    completion(SendEthResult.Error(CustomTokenError.badSymbolError))
                }
            }
        }
    }
    
    func decimals(for token: String, completion: @escaping (SendEthResult<BigUInt>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let contract = self.contract(for: token)
            let transaction = contract?.method("decimals", parameters: [AnyObject](), options: self.defaultOptions())
            let bkxBalance = transaction?.call(options: self.defaultOptions())
            DispatchQueue.main.async {
                if let balance = bkxBalance?.value?["0"] as? BigUInt {
                    completion(SendEthResult.Success(balance))
                }
                else {
                    completion(SendEthResult.Error(CustomTokenError.wrongBalanceError))
                }
            }
        }
    }
    
    
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    
    func getBalance(for token: String,
                    address: String,
                    completion: @escaping (SendEthResult<BigUInt>) -> Void) {
        completion(SendEthResult.Success(self.localGetBalance(for: token, address: address)))
        DispatchQueue.global(qos: .userInitiated).async {
            
            let ethAddress = EthereumAddress(address)
            guard ethAddress.isValid else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(UtilTransactionsErrors.invalidAddress))
                }
                return
            }
            
            let contract = self.contract(for: token)
            let parameters = [ethAddress]
            let transaction = contract?.method("balanceOf", parameters: parameters as [AnyObject], options: self.defaultOptions())
            let bkxBalance = transaction?.call(options: self.defaultOptions())
            DispatchQueue.main.async {
                // TODO: Fix me here
                if let balance = bkxBalance?.value?["balance"] as? BigUInt {
                    self.update(balance: balance, token: token, address: address)
                    completion(SendEthResult.Success(balance))
                }
                else {
                    DispatchQueue.main.async {
                        completion(SendEthResult.Success(self.localGetBalance(for: token, address: address)))
                    }
                }

            }
            
            return
        }
    }
    
    private func contract(for address: String) -> web3.web3contract? {
        let web3 = WalletWeb3Factory.web3()
        web3.addKeystoreManager(self.keysService.keystoreManager())
        
        let ethAddress = EthereumAddress(address)
        guard ethAddress.isValid else {
            return nil
        }
        return web3.contract(Web3.Utils.erc20ABI, at: ethAddress)
        /*("0x7EA2Df0F49D1cf7cb3a328f0038822B08AEB0aC1")) 0xe41d2489571d322189246dafa5ebde1f4699f498
         0x6ff6c0ff1d68b964901f986d4c9fa3ac68346570 - zrx on kovan
         0x5b0095100c1ce9736cdcb449a3199935a545ccce*/
    }
    
    private func defaultOptions() -> Web3Options {
        var options = Web3Options.defaultOptions()
        options.gasLimit = BigUInt(250000)
        options.gasPrice = BigUInt(250000000)
        options.from = EthereumAddress(self.keysService.selectedAddress()!)
        return options
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
                
                if let storedBalance = try? context.fetch(FetchRequest<TokenBalance>().filtered(with: NSPredicate(format: "token.address == %@ && wallet.address == %@  && networkUrl == %@", token, address, self.networkUrl))).first, storedBalance != nil {
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

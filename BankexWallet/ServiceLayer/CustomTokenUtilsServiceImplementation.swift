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

class CustomTokenUtilsServiceImplementation: UtilTransactionsService {
    
    func name(for token: String, completion: @escaping (SendEthResult<String>) -> Void) {
//        DispatchQueue.global(qos: .userInitiated).async {
            let contract = self.contract(for: token)
            let transaction = contract?.method("name", parameters: [AnyObject](), options: self.defaultOptions())
            let bkxBalance = transaction?.call(options: self.defaultOptions())
            DispatchQueue.main.async {
                //TODO: Somehow it crashes on second launch
                completion(SendEthResult.Success(bkxBalance!.value!["0"] as! String))
            }
//        }
    }
    
    func symbol(for token: String, completion: @escaping (SendEthResult<String>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let contract = self.contract(for: token)
            let transaction = contract?.method("symbol", parameters: [AnyObject](), options: self.defaultOptions())
            let bkxBalance = transaction?.call(options: self.defaultOptions())
            DispatchQueue.main.async {
                completion(SendEthResult.Success(bkxBalance!.value!["0"] as! String))
            }
        }
    }
    
    func decimals(for token: String, completion: @escaping (SendEthResult<BigUInt>) -> Void) {
//        DispatchQueue.global(qos: .userInitiated).async {
            let contract = self.contract(for: token)
            let transaction = contract?.method("decimals", parameters: [AnyObject](), options: self.defaultOptions())
            let bkxBalance = transaction?.call(options: self.defaultOptions())
//            DispatchQueue.main.async {
                completion(SendEthResult.Success(bkxBalance!.value!["0"] as! BigUInt))
//            }
//        }
    }
    
    
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    
    func getBalance(for token: String,
                    address: String,
                    completion: @escaping (SendEthResult<BigUInt>) -> Void) {
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
                completion(SendEthResult.Success(bkxBalance!.value!["balance"] as! BigUInt))
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
        options.gasPrice = BigUInt(25000000000)
        options.from = EthereumAddress(self.keysService.selectedAddress()!)
        return options
    }
}

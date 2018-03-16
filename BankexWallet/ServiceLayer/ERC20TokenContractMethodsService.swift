//
//  ERC20TokenContractMethodsService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/16/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class ERC20TokenContractMethodsServiceImplementation: SendEthService {
    let db = DBStorage.db

    func send(transaction: TransactionIntermediate, with password: String, completion: @escaping (SendEthResult<[String : String]>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = transaction.send()
            if let error = result.error {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(error))
                }
                return
            }
            guard let value = result.value else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.emptyResult))
                }
                return
            }
            do {
                try self.db.operation { (context, save) in
                    let newTask: SendEthTransaction = try context.new()
                    newTask.to = transaction.options?.to?.address
                    newTask.from = transaction.options?.from?.address
                    newTask.date = NSDate()
                    newTask.amount = transaction.options?.value?.description
                    try context.insert(newTask)
                    save()
                }
            } catch {
                //TODO: There was an error in the operation
            }
            DispatchQueue.main.async {
                completion(SendEthResult.Success(value))
            }
        }
    }
    
    
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    
    func prepareTransactionForSending(destinationAddressString: String,
                                      amountString: String,
                                      gasLimit: UInt,
                                      completion: @escaping (SendEthResult<TransactionIntermediate>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            let destinationEthAddress = EthereumAddress(destinationAddressString)
            if !destinationEthAddress.isValid {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.invalidDestinationAddress))
                }
                return
            }
            guard let amount = Web3.Utils.parseToBigUInt(amountString, toUnits: .eth) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.invalidAmountFormat))
                }
                return
            }
            let token = CustomERC20TokensServiceImplementation().selectedERC20Token().address
            let contract = self.contract(for: token)
            // to/ value
            let parameters = [destinationEthAddress, amount] as [Any]
            guard let transaction = contract?.method("transfer",
                                               parameters: parameters as [AnyObject],
                                               options: self.defaultOptions()) else {
                                                DispatchQueue.main.async {
                                                    completion(SendEthResult.Error(SendEthErrors.createTransactionIssue))
                                                }
                                                
                                                return
            }
            DispatchQueue.main.async {
                completion(SendEthResult.Success(transaction))
            }
            
            return
        }

    }
    
    func getAllTransactions() -> [SendEthTransaction]? {
        // TODO: Select only transacions with selected token?
        // TODO: Or show all of them??
        // Make a setting
        
        return nil
    }
    
    // TODO: Move these two to somewhere else
    private func contract(for address: String) -> web3.web3contract? {
        let web3 = WalletWeb3Factory.web3
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
        options.gasLimit = BigUInt(95000000000000)
        options.gasPrice = BigUInt(0.0000000001)
        options.from = EthereumAddress(self.keysService.preferredSingleAddress()!)
        return options
    }
}

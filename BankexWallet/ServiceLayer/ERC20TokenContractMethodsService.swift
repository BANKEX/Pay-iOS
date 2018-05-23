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
import SugarRecord

class ERC20TokenContractMethodsServiceImplementation: SendEthService {
    func send(transactionModel: ETHTransactionModel,
              transaction: TransactionIntermediate,
              with password: String,
              completion: @escaping (SendEthResult<[String : String]>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = transaction.send(password: password,
                                          options: transaction.options)
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
                    newTask.to = transactionModel.to
                    newTask.from = transactionModel.from
                    newTask.date = transactionModel.date
                    newTask.amount = transactionModel.amount
                    // TODO: Now we suppose that we can have only one with given address
                    let selectedTokenModel = CustomERC20TokensServiceImplementation().selectedERC20Token()
                    let token = try context.fetch(FetchRequest<ERC20Token>().filtered(with: "address", equalTo: selectedTokenModel.address))
                    newTask.token = token.first
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
    
    func delete(transaction: ETHTransactionModel) {
        
    }
    
    let db = DBStorage.db

    
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
            guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.invalidAmountFormat))
                }
                return
            }
            
            let web3 = WalletWeb3Factory.web3()
            web3.addKeystoreManager(self.keysService.keystoreManager())
            
            let token = CustomERC20TokensServiceImplementation().selectedERC20Token().address
            let contract = self.contract(for: token)
            var options = Web3Options.defaultOptions()
//            options.gasLimit = BigUInt(55000)
//            options.gasPrice = BigUInt(250000000)
            
            options.from = EthereumAddress(self.keysService.selectedAddress()!)
            guard let intermediate = web3.eth.sendERC20tokensWithNaturalUnits(tokenAddress: EthereumAddress(token), from: EthereumAddress(self.keysService.selectedAddress()!),
                                                                              to: destinationEthAddress,
                                                                              amount: amountString)
                
                else {
                    DispatchQueue.main.async {
                        completion(SendEthResult.Error(SendEthErrors.createTransactionIssue))
                    }
                    return
            }
            DispatchQueue.main.async {
                completion(SendEthResult.Success(intermediate))
            }

            return
            guard let _ = contract?.method(options: options)?.estimateGas(options: options).value else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.retrievingEstimatedGasError))
                }
                return
            }
            
//            options.gasLimit = estimatedGas + BigUInt(20000)
            guard let gasPrice = web3.eth.getGasPrice().value else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.retrievingGasPriceError))
                }
                return
            }
            options.gasPrice = gasPrice
            options.value = 0
            options.to = EthereumAddress(token)
            // to/ value
            let parameters = [destinationEthAddress,
                              amount] as [Any]
            guard let transaction = contract?.method("transfer",
                                               parameters: parameters as [AnyObject],
                                               options: options) else {
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
    
    func getAllTransactions() -> [ETHTransactionModel]? {
//         TODO: Select only transacions with selected token?
//         TODO: Or show all of them??
//         Make a setting
        let transactions: [SendEthTransaction] = try! db.fetch(FetchRequest<SendEthTransaction>().sorted(with: "date", ascending: false))
        return transactions.map({ (transaction) -> ETHTransactionModel in
            let token = transaction.token == nil ? ERC20TokenModel(name: "Ether", address: "", decimals: "18", symbol: "Eth", isSelected: false) :
                ERC20TokenModel(token: transaction.token!)
            return ETHTransactionModel(from: transaction.from ?? "",
                                       to: transaction.to ?? "",
                                       amount: transaction.amount ?? "",
                                       date: transaction.date!,
                                       token: token,
                                       key: HDKey(name: transaction.keywallet?.name,
                                                  address: (transaction.keywallet?.address ?? "")))
        })
    }
    
    // TODO: Move these two to somewhere else
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
//        options.gasLimit = BigUInt(21000)
//        options.gasPrice = BigUInt(25000)
        options.from = EthereumAddress(self.keysService.selectedAddress()!)
        return options
    }
}

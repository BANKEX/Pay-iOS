//
//  SendEthService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/12/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift
import BigInt
import SugarRecord

enum SendEthErrors: Error {
    case invalidDestinationAddress
    case invalidAmountFormat
    case contractLoadingError
    case retrievingGasPriceError
    case retrievingEstimatedGasError
    case emptyResult
    case noAvailableKeys
    case createTransactionIssue
}

enum SendEthResult<T> {
    case Success(T)
    case Error(Error)
}

protocol SendEthService {
    func prepareTransactionForSending(destinationAddressString: String,
                                      amountString: String,
                                      gasLimit: UInt,
                                      completion: @escaping (SendEthResult<TransactionIntermediate>) -> Void)
    
    func prepareTransactionForSending(destinationAddressString: String,
                                      amountString: String,
                                      completion: @escaping (SendEthResult<TransactionIntermediate>) -> Void)
    
    
    func send(transaction: TransactionIntermediate,
              with password: String,
              completion: @escaping (SendEthResult<[String: String]>) -> Void)
    
    func send(transaction: TransactionIntermediate, completion:
        @escaping (SendEthResult<[String: String]>) -> Void)
    
    func getAllTransactions() -> [SendEthTransaction]?
}

extension SendEthService {
    func send(transaction: TransactionIntermediate,
              completion: @escaping (SendEthResult<[String: String]>) -> Void)  {
        send(transaction: transaction, with: "BANKEXFOUNDATION", completion: completion)
    }
    
    func prepareTransactionForSending(destinationAddressString: String,
                                      amountString: String,
                                      completion: @escaping (SendEthResult<TransactionIntermediate>) ->Void) {
        prepareTransactionForSending(destinationAddressString: destinationAddressString, amountString: amountString, gasLimit: 21000, completion: completion)
    }
    
}

// TODO: check that correct address will be used
class SendEthServiceImplementation: SendEthService {
    
    func getAllTransactions() -> [SendEthTransaction]? {
        let transactions: [SendEthTransaction] = try! db.fetch(FetchRequest<SendEthTransaction>().sorted(with: "date", ascending: false))
        return transactions
    }
    
    let db: CoreDataDefaultStorage
    init() {
        let store = CoreDataStore.named("BankexWallet")
        let bundle = Bundle.main
        let model = CoreDataObjectModel.merged([bundle])
        db = try! CoreDataDefaultStorage(store: store, model: model)
    }
    
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    
    func send(transaction: TransactionIntermediate, with password: String = "BANKEXFOUNDATION", completion: @escaping (SendEthResult<[String: String]>) -> Void) {
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
    
    func prepareTransactionForSending(destinationAddressString: String,
                                      amountString: String,
                                      gasLimit: UInt = 21000,
                                      completion:  @escaping (SendEthResult<TransactionIntermediate>) -> Void) {
        DispatchQueue.global().async {
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
            
            let web3 = WalletWeb3Factory.web3
            guard let selectedKey = self.keysService.preferredSingleAddress() else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.noAvailableKeys))
                }
                return
            }
            let ethAddressFrom = EthereumAddress(selectedKey)
            web3.addKeystoreManager(self.keysService.keystoreManager())
            var options = Web3Options.defaultOptions()
            options.gasLimit = BigUInt(gasLimit)
            options.from = ethAddressFrom
            options.value = BigUInt(amount)
            guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destinationEthAddress) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.contractLoadingError))
                }
                return
            }
            
            guard let estimatedGas = contract.method(options: options)?.estimateGas(options: nil).value else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.retrievingEstimatedGasError))
                }
                return
            }
            options.gasLimit = estimatedGas
            guard let gasPrice = web3.eth.getGasPrice().value else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.retrievingGasPriceError))
                }
                return
            }
            options.gasPrice = gasPrice
            guard let transaction = contract.method(options: options) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.createTransactionIssue))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(SendEthResult.Success(transaction))
            }
        }
    }
    
    // MARK:
}

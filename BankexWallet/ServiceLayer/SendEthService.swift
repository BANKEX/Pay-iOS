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

struct ETHTransactionModel {
    let from: String
    let to: String
    let amount: String
    let date: Date
    let token: ERC20TokenModel
    let key: HDKey
    var isPending = false
}

protocol SendEthService {
    
    
    func prepareTransactionForSending(destinationAddressString: String,
                                      amountString: String,
                                      gasLimit: UInt,
                                      completion: @escaping (SendEthResult<TransactionIntermediate>) -> Void)
    
    func prepareTransactionForSending(destinationAddressString: String,
                                      amountString: String,
                                      completion: @escaping (SendEthResult<TransactionIntermediate>) -> Void)
    
    
    func send(transactionModel: ETHTransactionModel,
              transaction: TransactionIntermediate,
              with password: String,options: Web3Options?,
              completion: @escaping (SendEthResult<TransactionSendingResult>) -> Void)
    
    func send(transactionModel: ETHTransactionModel,
              transaction: TransactionIntermediate, options: Web3Options?, completion:
        @escaping (SendEthResult<TransactionSendingResult>) -> Void)
    
    func getAllTransactions() -> [ETHTransactionModel]
    
    func delete(transaction: ETHTransactionModel)
}

extension SendEthService {
    func send(transactionModel: ETHTransactionModel,
              transaction: TransactionIntermediate, options: Web3Options? = nil,
              completion: @escaping (SendEthResult<TransactionSendingResult>) -> Void)  {
        send(transactionModel: transactionModel,
             transaction: transaction,
             with: "BANKEXFOUNDATION", options: options,
             completion: completion)
    }
    
    func prepareTransactionForSending(destinationAddressString: String,
                                      amountString: String,
                                      completion: @escaping (SendEthResult<TransactionIntermediate>) ->Void) {
        prepareTransactionForSending(destinationAddressString: destinationAddressString, amountString: amountString, gasLimit: 21000, completion: completion)
    }
    
}

// TODO: check that correct address will be used
class SendEthServiceImplementation: SendEthService {
    
    func send(transactionModel: ETHTransactionModel, transaction: TransactionIntermediate, with password: String, options: Web3Options? = nil, completion: @escaping (SendEthResult<TransactionSendingResult>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = transaction.send(password: password, options: options)
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
                    let selectedKey = try context.fetch(FetchRequest<KeyWallet>().filtered(with: NSPredicate(format: "isSelected == %@", NSNumber(value: true)))).first
                    let tokenModel = CustomERC20TokensServiceImplementation().selectedERC20Token()
                    let selectedToken = try context.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "address == %@", tokenModel.address))).first
                    newTask.to = transactionModel.to.lowercased()
                    newTask.from = transactionModel.from.lowercased()
                    newTask.date = transactionModel.date as Date
                    newTask.amount = transactionModel.amount.stripZeros()
                    newTask.keywallet = selectedKey
                    newTask.token = selectedToken
                    newTask.networkId = Int64(NetworksServiceImplementation().preferredNetwork().networkId)
                    newTask.trHash = result.value?.transaction.txhash
                    newTask.isPending = true
                    try context.insert(newTask)
                    save()
                }
            } catch {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.createTransactionIssue))
                }
                return
            }
            DispatchQueue.main.async {
                completion(SendEthResult.Success(value))
            }
        }
    }
    
    
    func delete(transaction: ETHTransactionModel) {
        do {
            try db.operation({ (context, save) in
                
                let transactionToDelete = try context.fetch(FetchRequest<SendEthTransaction>().filtered(with: NSPredicate(format:"from == %@ && to == %@ && date == %@", transaction.from, transaction.to, transaction.date as NSDate)))
                try context.remove(transactionToDelete)
                save()
            })
        }
        catch {
            
        }
    }
    
    
    func getAllTransactions() -> [ETHTransactionModel] {
        guard let address = self.keysService.selectedAddress() else { return [] }
        let networkId = Int64(NetworksServiceImplementation().preferredNetwork().networkId)
        
        let transactions: [SendEthTransaction] = try! db.fetch(FetchRequest<SendEthTransaction>().filtered(with: NSPredicate(format: "networkId == %@ && (from == %@ || to == %@) && token == nil", NSNumber(value: networkId), address.lowercased(), address.lowercased())).sorted(with: "date", ascending: false))
        
        return transactions.map({ (transaction) -> ETHTransactionModel in
            let token = transaction.token == nil ? ERC20TokenModel(name: "Ether", address: "", decimals: "18", symbol: "Eth", isSelected: false) :
                ERC20TokenModel(token: transaction.token!)
            return ETHTransactionModel(from: transaction.from ?? "",
                                       to: transaction.to ?? "",
                                       amount: transaction.amount ?? "",
                                       date: transaction.date!,
                                       token: token,
                                       key: HDKey(name: transaction.keywallet?.name,
                                                  address: (transaction.keywallet?.address ?? "")), isPending: transaction.isPending)
        })
    }
    
    let db = DBStorage.db    
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    
    func send(transaction: TransactionIntermediate, with password: String = "BANKEXFOUNDATION", completion: @escaping (SendEthResult<TransactionSendingResult>) -> Void) {
        
    }
    
    func prepareTransactionForSending(destinationAddressString: String,
                                      amountString: String,
                                      gasLimit: UInt = 21000,
                                      completion:  @escaping (SendEthResult<TransactionIntermediate>) -> Void) {
        DispatchQueue.global().async {
            guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {
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
            guard let selectedKey = self.keysService.selectedAddress() else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.noAvailableKeys))
                }
                return
            }
            let ethAddressFrom = EthereumAddress(selectedKey)
            web3.addKeystoreManager(self.keysService.keystoreManager())
            var options = Web3Options.defaultOptions()
//            options.gasLimit = BigUInt(gasLimit)
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

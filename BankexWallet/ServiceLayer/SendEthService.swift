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

protocol SendEthService {
    func prepareTransactionForSending(destinationAddressString: String,
                                      amountString: String,
                                      gasLimit: UInt) throws -> TransactionIntermediate
    
    func send(transaction: TransactionIntermediate,
              with password: String) throws -> [String: String]
    
    func send(transaction: TransactionIntermediate) throws -> [String: String]
}

extension SendEthService {
    func send(transaction: TransactionIntermediate) throws -> [String: String] {
        return try send(transaction: transaction, with: "BANKEXFOUNDATION")
    }
}

// TODO: check that correct address will be used
class SendEthServiceImplementation: SendEthService {
    
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    
    func send(transaction: TransactionIntermediate, with password: String = "BANKEXFOUNDATION") throws -> [String: String] {
        let result = transaction.send()
        if let error = result.error {
            throw error
        }
        guard let value = result.value else {
            throw SendEthErrors.emptyResult
        }
        return value
    }
    
    func prepareTransactionForSending(destinationAddressString: String,
                                      amountString: String,
                                      gasLimit: UInt = 21000) throws -> TransactionIntermediate {
        
        let destinationEthAddress = EthereumAddress(destinationAddressString)
        if !destinationEthAddress.isValid {
            throw SendEthErrors.invalidDestinationAddress
        }
        guard let amount = Web3.Utils.parseToBigUInt(amountString, toUnits: .eth) else {
            throw SendEthErrors.invalidAmountFormat
        }
        
        let web3 = WalletWeb3Factory.web3
        guard let selectedKey = keysService.preferredSingleAddress() else {
                throw SendEthErrors.noAvailableKeys
        }
        let ethAddressFrom = EthereumAddress(selectedKey)
        web3.addKeystoreManager(keysService.keystoreManager())
        var options = Web3Options.defaultOptions()
        options.gasLimit = BigUInt(gasLimit)
        options.from = ethAddressFrom
        options.value = BigUInt(amount)
        guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destinationEthAddress) else {
            throw SendEthErrors.contractLoadingError
        }

        guard let estimatedGas = contract.method(options: options)?.estimateGas(options: nil).value else {
            throw SendEthErrors.retrievingEstimatedGasError
        }
        options.gasLimit = estimatedGas
        guard let gasPrice = web3.eth.getGasPrice().value else {
            throw SendEthErrors.retrievingGasPriceError
        }
        options.gasPrice = gasPrice
        guard let transaction = contract.method(options: options) else {
            throw SendEthErrors.createTransactionIssue
        }
        return transaction
    }
}

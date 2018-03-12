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
}

protocol SendEthService {
    func prepareTransactionForSending(destinationAddressString: String,
                                      amountString: String,
                                      gasLimit: UInt) throws -> TransactionIntermediate?
    
    func send(transaction: TransactionIntermediate,
              with password: String) throws -> [String: String]
}

class SendEthServiceImplementation: SendEthService {
    
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
                                      gasLimit: UInt = 21000) throws -> TransactionIntermediate? {
        
        let destinationEthAddress = EthereumAddress(destinationAddressString)
        if !destinationEthAddress.isValid {
            throw SendEthErrors.invalidDestinationAddress
        }
        guard let amount = Web3.Utils.parseToBigUInt(amountString, toUnits: .eth) else {
            throw SendEthErrors.invalidAmountFormat
        }

        let web3 = WalletWeb3Factory.web3
        // TODO: Add KeyStore Here to web3
        
        var options = Web3Options.defaultOptions()
        options.gasLimit = BigUInt(gasLimit)
        // TODO: Setup current address
//        options.from = self.address
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
        return contract.method(options: options)
    }
    
    func sendEth(transaction: Any) throws {
        
    }
}

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
    func getBalance(for address: String) throws -> BigUInt
}

class UtilTransactionsServiceImplementation: UtilTransactionsService {
    
    func getBalance(for address: String) throws -> BigUInt {
        let web3 = WalletWeb3Factory.web3
        let ethAddress = EthereumAddress(address)
        guard ethAddress.isValid else {
            throw UtilTransactionsErrors.invalidAddress
        }
        let result = web3.eth.getBalance(address: ethAddress)
        guard result.error == nil,
        let resultValue = result.value else {
            throw UtilTransactionsErrors.transactionError
        }
        return resultValue
    }
    
}

//
//  TransactionDetailsService.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 24/12/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import Foundation
import web3swift
import BigInt
import Result

protocol TransactionDetailsService {
    func getTransactionDetails(txHash: String, completion: @escaping (TransactionDetails?)->Void)
    func getStatus(txHash: String, completion: @escaping (TransactionReceipt.TXStatus?) -> Void)
}

struct TransactionDetails {
    let gasLimit: BigUInt
    let gasPrice: BigUInt
    let blockNumber: BigUInt?
}

class TransactionDetailsServiceImplementation: TransactionDetailsService {
    
    func getTransactionDetails(txHash: String, completion: @escaping (TransactionDetails?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let web3 = WalletWeb3Factory.web3()
            let result: Result<web3swift.TransactionDetails, Web3Error> = web3.eth.getTransactionDetails(txHash)
            let txDetails: TransactionDetails? = {
                guard let value = result.value else {
                    return nil
                }
                return TransactionDetails(
                    gasLimit: value.transaction.gasLimit,
                    gasPrice: value.transaction.gasPrice,
                    blockNumber: value.blockNumber)
            }()
            DispatchQueue.main.async {
                completion(txDetails)
            }
        }
    }
    
    func getStatus(txHash: String, completion: @escaping (TransactionReceipt.TXStatus?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let web3 = WalletWeb3Factory.web3()
            let result: Result<TransactionReceipt, Web3Error> = web3.eth.getTransactionReceipt(txHash)
            DispatchQueue.main.async {
                completion(result.value?.status)
            }
        }
    }
}

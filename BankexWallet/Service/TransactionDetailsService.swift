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
    func getGasLimit(txHash: String, completion: @escaping (BigUInt?)->Void)
    func getGasPrice(txHash: String, completion: @escaping (BigUInt?)->Void)
    func getBlockNumber(txHash: String, completion: @escaping (BigUInt?) -> Void)
    func getStatus(txHash: String, completion: @escaping (TransactionReceipt.TXStatus?) -> Void)
}

class TransactionDetailsServiceImplementation: TransactionDetailsService {
    
    func getGasLimit(txHash: String, completion: @escaping (BigUInt?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let web3 = WalletWeb3Factory.web3()
            let result: Result<TransactionDetails, Web3Error> = web3.eth.getTransactionDetails(txHash)
            DispatchQueue.main.async {
                completion(result.value?.transaction.gasLimit)
            }
        }
    }
    
    func getGasPrice(txHash: String, completion: @escaping (BigUInt?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let web3 = WalletWeb3Factory.web3()
            let result: Result<TransactionDetails, Web3Error> = web3.eth.getTransactionDetails(txHash)
            DispatchQueue.main.async {
                completion(result.value?.transaction.gasPrice)
            }
        }
    }
    
    func getBlockNumber(txHash: String, completion: @escaping (BigUInt?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let web3 = WalletWeb3Factory.web3()
            let result: Result<TransactionDetails, Web3Error> = web3.eth.getTransactionDetails(txHash)
            DispatchQueue.main.async {
                completion(result.value?.blockNumber)
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

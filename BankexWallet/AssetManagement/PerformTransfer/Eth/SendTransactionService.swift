//
//  TransactionPreparation.swift
//  BankexWallet
//
//  Created by Vladislav on 28/11/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import Foundation
import web3swift
import BigInt





class SendTransactionService {
    
    let keyService = SingleKeyServiceImplementation()
    let sendETHService = SendEthServiceImplementation()
    var amount:String
    var toAddress:String
    var transactionIntermediate:TransactionIntermediate?
    let gasLimit = "21000"
    let transactionService = TransactionsService()
    
    init(toAddress to:String, amount:String) {
        self.amount = amount
        self.toAddress = to
    }
    
    func sendTransaction(completion:@escaping (SendEthResult<TransactionSendingResult>) -> Void) {
        guard let transactionETHModel = createETHTransactionModel() else { return }
        sendETHService.prepareTransactionForSending(destinationAddressString: toAddress, amountString: amount) { result in
            switch result {
            case .Success(let trans):
                self.transactionIntermediate = trans
                self.getWeb3options(complited: { options in
                    guard let transIntermediate = self.transactionIntermediate else { return }
                    self.sendETHService.send(transactionModel: transactionETHModel, transaction: transIntermediate, options: options) { result in
                        completion(result)
                    }
                })
            case .Error(let error):
                printDebug(error.localizedDescription)
            }
        }
    }
    
    
    private func getWeb3options(complited:@escaping (Web3Options) -> ()) {
        var options = Web3Options.defaultOptions()
        options.from = transactionIntermediate?.options?.from
        options.to = transactionIntermediate?.options?.to
        options.value = transactionIntermediate?.options?.value
        options.gasLimit = gasLimit.toBigInt
        transactionService.requestGasPrice { gasPrice in
            guard let gasPrice = gasPrice else { return }
            options.gasPrice = BigUInt(gasPrice.toWei)
            complited(options)
        }
    }
    
    private func createETHTransactionModel() -> ETHTransactionModel? {
        let ethToken = createETHModel()
        guard let fromAddress = keyService.selectedAddress() else { return nil }
        guard let selectedKey = keyService.selectedKey() else { return nil }
        let transaction = ETHTransactionModel.init(from: fromAddress, to: toAddress, amount: amount, date: Date(), token: ethToken, key: selectedKey, isPending: false)
        return transaction
    }
    
    private func createETHModel() -> ERC20TokenModel {
        return ERC20TokenModel(name: "Ether", address: "", decimals: "18", symbol: "Eth", isSelected: false, isSecurity:false)
    }
}

extension String {
    var toBigInt:BigUInt? {
        return BigUInt(self)
    }
}

extension Double {
    var toWei:Double {
        return self * pow(10, 9)
    }
}

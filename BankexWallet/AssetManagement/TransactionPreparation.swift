//
//  TransactionPreparation.swift
//  BankexWallet
//
//  Created by Vladislav on 28/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import web3swift
import BigInt





class PreparetionTransaction {
    
    let keyService = SingleKeyServiceImplementation()
    let sendETHService = SendEthServiceImplementation()
    var amount:String
    var toAddress:String
    var transactionIntermediate:TransactionIntermediate?
    let gasPrice:Double = 15
    let gasLimit = "21001"
    
    init(toAddress to:String, amount:String) {
        self.amount = amount
        self.toAddress = to
    }
    
    func sendTransaction() {
        guard let transactionETHModel = createETHTransactionModel() else { return }
        sendETHService.prepareTransactionForSending(destinationAddressString: toAddress, amountString: amount) { result in
            switch result {
            case .Success(let trans):
                self.transactionIntermediate = trans
            case .Error(let error):
                printDebug(error.localizedDescription)
            }
        }
        let options = getWeb3options()
        guard let transIntermediate = transactionIntermediate else { return }
        sendETHService.send(transactionModel: transactionETHModel, transaction: transIntermediate, options: options) { _ in }
    }
    
    
    
    
    
    private func getWeb3options() -> Web3Options {
        var options = Web3Options.defaultOptions()
        options.from = transactionIntermediate?.options?.from
        options.to = transactionIntermediate?.options?.to
        options.value = transactionIntermediate?.options?.value
        return options
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

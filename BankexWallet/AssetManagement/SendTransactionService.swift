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





class SendTransactionService {
    
    let keyService = SingleKeyServiceImplementation()
    let sendETHService = SendEthServiceImplementation()
    var amount:String
    var toAddress:String
    var transactionIntermediate:TransactionIntermediate?
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
                self.getWeb3options(complited: { options in
                    guard let transIntermediate = self.transactionIntermediate else { return }
                    self.sendETHService.send(transactionModel: transactionETHModel, transaction: transIntermediate, options: options) { _ in }
                })
            case .Error(let error):
                printDebug(error.localizedDescription)
            }
        }
    }
    
    func requestGasPrice(onComplition:@escaping (Double) -> Void) {
        let path = "https://ethgasstation.info/json/ethgasAPI.json"
        guard let url = URL(string: path) else {
            DispatchQueue.main.async {
                onComplition(0)
            }
            return
        }
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                printDebug(error.localizedDescription)
                DispatchQueue.main.async {
                    onComplition(0)
                }
                return
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    let gasPrice = json["average"] as! Double
                    DispatchQueue.main.async {
                        onComplition(gasPrice)
                    }
                }catch {
                    DispatchQueue.main.async {
                        onComplition(0)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    
    private func getWeb3options(complited:@escaping (Web3Options) -> ()) {
        var options = Web3Options.defaultOptions()
        options.from = transactionIntermediate?.options?.from
        options.to = transactionIntermediate?.options?.to
        options.value = transactionIntermediate?.options?.value
        options.gasLimit = gasLimit.toBigInt
        requestGasPrice { gasPrice in
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

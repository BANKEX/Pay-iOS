//
//  TransactionsService.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 31/07/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import web3swift
import SugarRecord

class TransactionsService {
    
    let blockExplorer = BlockExplorer()
    let db = DBStorage.db
    
    func getAndMergeAllTransactionsMainNet(forAddress address: String, completion: @escaping (Bool)->Void) {
        DispatchQueue.global().async {
            do {
                let transactions = try self.blockExplorer.getTransactionsHistory(address: address).wait()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                try self.db.operation({ (context, save) in
                    for transaction in transactions {
                        if let newTask = try context.fetch(FetchRequest<SendEthTransaction>().filtered(with: NSPredicate(format: "txHash == %@", transaction.hash.toHexString()))).first {
                            newTask.isPending = false
                            save()
                        } else {
                            let newTask: SendEthTransaction = try context.new()
                            let selectedKey = try context.fetch(FetchRequest<KeyWallet>().filtered(with: NSPredicate(format: "isSelected == %@", NSNumber(value: true)))).first
                            let tokenModel = CustomERC20TokensServiceImplementation().selectedERC20Token()
                            let selectedToken = try context.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "address == %@", tokenModel.address))).first
                            newTask.to = transaction.addressTo.address
                            newTask.from = transaction.addressFrom.address
                            
                            newTask.date = dateFormatter.date(from: transaction.isoTime)
                            //TODO: - not sure that it is correct
                            newTask.amount = transaction.value.description
                            newTask.keywallet = selectedKey
                            newTask.token = selectedToken
                            newTask.networkId = 1
                            try context.insert(newTask)
                            save()
                        }
                    }
                    
                    completion(true)
                })
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
        
    }
}

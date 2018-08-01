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
import BigInt

class TransactionsService {
    
    let db = DBStorage.db
    
    //A function which purpose is to load data from the network and merge it with transactions, that already exists
    func refreshTransactionsInSelectedNetwork(forAddress address: String, completion: @escaping(Bool) -> Void) {
        let networkId = Int64(NetworksServiceImplementation().preferredNetwork().networkId)
        var urlPart: String
        switch networkId {
        case 1:
            urlPart = ""
        case 3:
            urlPart = "-ropsten"
        case 4:
            urlPart = "-rinkeby"
        case 42:
            urlPart = "-kovan"
        default:
            urlPart = ""
        }
        
        let url = URL(string: "https://api\(urlPart).etherscan.io/api?module=account&action=txlist&address=\(address)&startblock=0&endblock=99999999&sort=asc&apikey=S1XHDZ1XJ2H4KR7G32RZJIS5DZIAVS1171")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error ?? "")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            guard let data = data else { return }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return }
                guard let results = json["result"] as? [[String: Any]] else { return }
                for result in results {
                    guard let from = result["from"] as? String else { return }
                    guard let to = result["to"] as? String else { return }
                    guard let timestamp = Double(result["timeStamp"] as! String) else { return }
                    guard let value = BigUInt(result["value"] as! String) else { return }
                    guard let hash = result["hash"] as? String else { return }
                    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
                    let transaction = Transaction(addressFrom: from, addressTo: to, trHash: hash, value: Web3.Utils.formatToEthereumUnits(value)!, date: date)
                    try self.db.operation({ (context, save) in
                        if let newTask = try context.fetch(FetchRequest<SendEthTransaction>().filtered(with: NSPredicate(format: "trHash == %@", transaction.trHash))).first {
                            newTask.isPending = false
                            save()
                        } else {
                            let newTask: SendEthTransaction = try context.new()
                            let selectedKey = try context.fetch(FetchRequest<KeyWallet>().filtered(with: NSPredicate(format: "isSelected == %@", NSNumber(value: true)))).first
                            let tokenModel = CustomERC20TokensServiceImplementation().selectedERC20Token()
                            let selectedToken = try context.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "address == %@", tokenModel.address))).first
                            newTask.to = transaction.addressTo
                            newTask.from = transaction.addressFrom
                            newTask.trHash = transaction.trHash
                            newTask.date = transaction.date
                            newTask.amount = transaction.value
                            newTask.keywallet = selectedKey
                            newTask.token = selectedToken
                            newTask.networkId = networkId
                            try context.insert(newTask)
                            save()
                        }
                        
                    })
                }
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
                print(error)
            }
        }
        dataTask.resume()
    }
}


struct Transaction {
    let addressFrom: String
    let addressTo: String
    let trHash: String
    let value: String
    let date: Date
    
}

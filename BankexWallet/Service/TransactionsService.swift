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
    var networkId: Int64 {
        return Int64(NetworksServiceImplementation().preferredNetwork().networkId)
    }
    
    var urlPart: String {
            switch networkId {
            case 1:
                return ""
            case 3:
                return "-ropsten"
            case 4:
                return "-rinkeby"
            case 42:
                return "-kovan"
            default:
                return ""
            }
    }
    
    enum TrType {
        case ETH
        case Tokens
    }
    
    //A function which purpose is to load data from the network and merge it with transactions, that already exists
    func refreshTransactionsInSelectedNetwork(type: TrType = .ETH,forAddress address: String, completion: @escaping(Bool) -> Void) {
        let tokenModel = CustomERC20TokensServiceImplementation().selectedERC20Token()
        var type: TrType
        if tokenModel.symbol.uppercased() == "ETH" {
            type = .ETH
        } else {
            type = .Tokens
        }
        var url: URL
        switch type {
        case .ETH:
            url = URL(string: "https://api\(urlPart).etherscan.io/api?module=account&action=txlist&address=\(address)&startblock=0&endblock=99999999&sort=asc")!
        case .Tokens:
            url = URL(string: "https://api\(urlPart).etherscan.io/api?module=account&action=tokentx&address=\(address)&startblock=0&endblock=99999999&sort=asc")!
            
        }
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
                    if type != .ETH {
                        guard let tokenAddress  = result["contractAddress"] as? String else { return }
                        guard tokenModel.address == tokenAddress else { continue }
                    }
                    guard let from = result["from"] as? String,
                        let to = result["to"] as? String,
                        let timestamp = Double(result["timeStamp"] as! String),
                        let value = BigUInt(result["value"] as! String),
                        let hash = result["hash"] as? String else { return }
                    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
                    try self.db.operation({ (context, save) in
                        if let newTask = try context.fetch(FetchRequest<SendEthTransaction>().filtered(with: NSPredicate(format: "trHash == %@", hash))).first {
                            newTask.isPending = false
                            newTask.to = newTask.to?.lowercased()
                            newTask.from = newTask.from?.lowercased()
                            newTask.networkId = self.networkId
                            newTask.amount = newTask.amount!.stripZeros()
                            save()
                        } else {
                            let newTask: SendEthTransaction = try context.new()
                            let selectedKey = try context.fetch(FetchRequest<KeyWallet>().filtered(with: NSPredicate(format: "isSelected == %@", NSNumber(value: true)))).first
                            let selectedToken = try context.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "address == %@", tokenModel.address))).first
                            newTask.to = to
                            newTask.from = from
                            newTask.trHash = hash
                            newTask.date = date
                            newTask.amount = Web3.Utils.formatToEthereumUnits(value)!.stripZeros()
                            newTask.keywallet = selectedKey
                            newTask.token = selectedToken
                            newTask.networkId = self.networkId
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
    
    func stripZeros(_ string: String) -> String {
        if !string.contains(".") {return string}
        var end = string.index(string.endIndex, offsetBy: -1)
        
        print(string[end])
        while string[end] == "0" {
            end = string.index(before: end)
        }
        if string[end] == "." {
            if string[string.index(before: end)] == "0" {
                return "0.0"
            } else {
                return string[...end] + "0"
            }
        }
        return String(string[...end])
    }

}

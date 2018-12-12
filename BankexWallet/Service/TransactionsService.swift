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
    let tokenModel = CustomERC20TokensServiceImplementation().selectedERC20Token()
    var isEtherToken:Bool {
        let tokenModel = CustomERC20TokensServiceImplementation().selectedERC20Token()
        return tokenModel.address.isEmpty ? true : false
    }
    var currentType:TrType {
        if isEtherToken {
            return .ETH
        }
        return .Tokens
    }
    var currentNode: Node {
            switch networkId {
            case 1:
                return .mainnet
            case 3:
                return .ropsten
            case 4:
                return .rinkeby
            case 42:
                return .kovan
            default:
                return .mainnet
            }
    }
    
    
    enum Node:String {
        case ropsten = "-ropsten"
        case rinkeby = "-rinkeby"
        case kovan = "-kovan"
        case mainnet = ""
    }
    
    enum TrType:String {
        case ETH = "txlist"
        case Tokens = "tokentx"
    }
    
    func matchContactAddress(_ contractAddress:String) -> Bool {
        return tokenModel.address == contractAddress
    }
    
    
    func choosenNode(_ node:Node?) -> Bool {
        guard let _ = node else { return false }
        return true
    }
    func choosenType(_ type:TrType?) -> Bool {
        guard let _ = type else { return false }
        return true
    }
    
    func requestGasPrice(onComplition:@escaping (Double?) -> Void) {
        let path = "https://ethgasstation.info/json/ethgasAPI.json"
        guard let url = URL(string: path) else {
            DispatchQueue.main.async {
                onComplition(nil)
            }
            return
        }
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                printDebug(error.localizedDescription)
                DispatchQueue.main.async {
                    onComplition(nil)
                }
                return
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                    let gasPrice = json?["average"] as? Double
                    DispatchQueue.main.async {
                        onComplition(gasPrice)
                    }
                }catch {
                    DispatchQueue.main.async {
                        onComplition(nil)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    //A function which purpose is to load data from the network and merge it with transactions, that already exists
    func refreshTransactionsInSelectedNetwork(type: TrType?,forAddress address: String,node:Node?, completion: @escaping(Bool) -> Void) {
        let checkedNode = choosenNode(node) ? node! : currentNode
        let checkedType = choosenType(type) ? type! : currentType
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api\(checkedNode.rawValue).etherscan.io"
        components.path = "/api"
        components.queryItems = {
            [URLQueryItem(name: "module", value: "account"),URLQueryItem(name: "action", value: checkedType.rawValue),URLQueryItem(name: "address", value: address),URLQueryItem(name: "startblock", value: "0"),URLQueryItem(name: "endblock", value: "99999999"),URLQueryItem(name: "sort", value: "asc")]
        }()
        guard let url = components.url else { return }
        let request = URLRequest(url: url)
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
                    if checkedType != .ETH {
                        guard let contractAddress  = result["contractAddress"] as? String else { return }
                        guard self.matchContactAddress(contractAddress) else { continue }
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
                            newTask.to = to.lowercased()
                            newTask.from = newTask.from?.lowercased()
                            newTask.networkId = self.networkId
                            newTask.amount = newTask.amount!.stripZeros()
                            save()
                        } else {
                            let newTask: SendEthTransaction = try context.new()
                            let selectedKey = try context.fetch(FetchRequest<KeyWallet>().filtered(with: NSPredicate(format: "isSelected == %@", NSNumber(value: true)))).first
                            let selectedToken = try context.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "address == %@", self.tokenModel.address))).first
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



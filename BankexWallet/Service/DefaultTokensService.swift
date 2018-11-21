//
//  DefaultTokensService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 15/5/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import SugarRecord
import SDWebImage

protocol DefaultTokensService {
    func downloadAllAvailableTokensIfNeeded( completion: @escaping ()-> Void)}



class DefaultTokensServiceImplementation: DefaultTokensService {
    
    private let defaultsKey = "didDownloadAllAvailableTokens"
    private let db = DBStorage.db
    private let networksService = NetworksServiceImplementation()
    private let tokensService: UtilTransactionsService = CustomTokenUtilsServiceImplementation()
    
    func downloadAllAvailableTokensIfNeeded( completion: @escaping ()-> Void) {
        if UserDefaults.standard.bool(forKey: defaultsKey) {
            completion()
            return
        }
    
        guard let url = URL(string: "https://raw.githubusercontent.com/BANKEX/Tokens/master/listTokens") else {
            completion()
            return
        }
        
        
        
        var numberOfAddedTokens = 0
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    // Convert the data to JSON
                    if let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
                        numberOfAddedTokens = jsonSerialized.count
                        var addresses = [String]()
                        try jsonSerialized.forEach({ (dict) in
                            try self.db.operation { (context, save) in
                                
                                var newToken: ERC20Token
                                if let token = try context.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "address == %@", dict["address"] as! String))).first {
                                    newToken = token
                                } else {
                                    newToken = try context.new()
                                }
                                addresses.append((dict["address"] as? String)!)
                                newToken.address = dict["address"] as? String
                                newToken.symbol = dict["symbol"] as? String
                                newToken.name = newToken.symbol
                                newToken.decimals = String((dict["decimal"] as? Int) ?? 0)
                                newToken.networkURL =  self.networksService.preferredNetwork().fullNetworkUrl.absoluteString
                                try context.insert(newToken)
                                save()
                                numberOfAddedTokens -= 1
                                if numberOfAddedTokens == 0 {
                                    DispatchQueue.main.async {
                                        self.updateNames(addresses: addresses, completion: completion)
                                        completion()
                                    }
                                }
                            }
                        })
                    }
                }  catch  {
                    completion()
                }
            } else  {
                completion()
            }
        }
        task.resume()
    }
    
    // For now this is quit useless, as we have only 4 names out of 600 so stupid spending time
    func updateNames(addresses: [String], completion: @escaping ()->Void) {
        UserDefaults.standard.set(true, forKey: self.defaultsKey)
        return;
        let date = NSDate()
        var numberOfAddedTokens = addresses.count
        addresses.forEach { (address) in
            self.tokensService.name(for: (address) , completion: { (result) in
                numberOfAddedTokens -= 1
                if numberOfAddedTokens == 0 {
                    UserDefaults.standard.set(true, forKey: self.defaultsKey)
                    DispatchQueue.main.async {
//                        completion()
                    }
                }
                do {
                    switch result {
                    case .Success(let localName):
                        print("No error! ")

                        try self.db.operation { (context, save) in
                            let token = try context.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "address == %@", address))).first
                            if let token = token {
                                token.name = localName
                                save()
                            }
                        }
                    case .Error(_):
                        print("")
                    }
                }
                catch {
//                    completion()
                }
                
                
            })
        }
        
    }
    
    
}

extension UIImageView {
    func setTokenImage(tokenAddress:String) {
        let path = "https://raw.githubusercontent.com/TrustWallet/tokens/master/images/\(tokenAddress).png"
        if let url = URL(string:path) {
            self.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "Group"))
        }
    }
    
    func setBKXImage() {
        self.sd_setImage(with: nil, placeholderImage: #imageLiteral(resourceName: "Bankex"))
    }
}



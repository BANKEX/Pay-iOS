//
//  CustomERC721TokensService.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 20.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import SugarRecord
import BigInt
import web3swift

struct ERC721TokenModel {
    let name: String
    let address: String
    let decimals: String
    let symbol: String
    let isSelected: Bool
    
    init(token: ERC721Token) {
        self.name = token.name ?? ""
        self.address = token.address ?? ""
        self.decimals = token.decimals ?? ""
        self.symbol = token.symbol ?? ""
        self.isSelected = token.isSelected
    }
    
    init(name: String,
         address: String,
         decimals: String,
         symbol: String,
         isSelected: Bool) {
        self.name = name
        self.address = address
        self.decimals = decimals
        self.symbol = symbol
        self.isSelected = isSelected
    }
}

extension ERC721TokenModel: Equatable {
    static func == (lhs: ERC721TokenModel, rhs: ERC721TokenModel) -> Bool {
        return
            lhs.name == rhs.name &&
                lhs.address == rhs.address &&
                lhs.decimals == rhs.decimals &&
                lhs.symbol == rhs.symbol
    }
}

protocol CustomERC721TokensService {
    func addNewCustomToken(with address: String,
                           name: String,
                           decimals: String,
                           symbol: String)
    
    func searchForCustomToken(with address: String,
                              completion: @escaping (SendEth721Result<ERC721TokenModel>) -> Void)
    
    func getTokensList(with address: String, completion: @escaping (SendEth721Result<[ERC721TokenModel]>) -> Void)
    
    func selectedERC721Token() -> ERC721TokenModel
    
    func updateSelectedToken(to token: String, completion: (() -> Void)? )
    
    func deleteToken(with address: String)
    
    func availableTokensList() -> [ERC721TokenModel]?
    
    func resetSelectedToken()
    
    func updateConversions()
    
    func getNewConversion(for token: String)
}


class CustomERC721TokensServiceImplementation: CustomERC721TokensService {
    
    let conversionService = FiatServiceImplementation.service
    
    func resetSelectedToken() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.db.operation { (context, save) in
                    guard let oldSelectedToken = try context.fetch(FetchRequest<ERC721Token>().filtered(with: NSPredicate(format: "isSelected == %@", NSNumber(value: true)))).first else {
                        return
                    }
                    oldSelectedToken.isSelected = false
                    save()
                }
            } catch {
                //TODO: There was an error in the operation
            }
            
        }
    }
    
    func addNewCustomToken(with address: String, name: String, decimals: String, symbol: String) {
        //        DispatchQueue.global(qos: .userInitiated).async {
        self.resetSelectedToken()
        do {
            try self.db.operation { (context, save) in
                var newToken: ERC721Token
                if let token = try context.fetch(FetchRequest<ERC721Token>().filtered(with: NSPredicate(format: "address == %@", address))).first {
                    newToken = token
                } else {
                    newToken = try context.new()
                }
                newToken.address = address
                newToken.name = name
                newToken.symbol = symbol
                newToken.decimals = decimals.description
                newToken.isAdded = true
                newToken.isSelected = true
                newToken.networkURL = self.networksService.preferredNetwork().fullNetworkUrl.absoluteString
                try context.insert(newToken)
                save()
            }
        } catch {
            //TODO: There was an error in the operation
        }
        //        }
    }
    
    
    private func makeOnlineSearchToken(with address: String, completion: @escaping (SendEth721Result<ERC721TokenModel>) -> Void) {
        
        guard let _ = EthereumAddress(address) else {
            completion(SendEth721Result.Error(CustomTokenError.undefinedError))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            var name: String = ""
            self.tokensUtilService.name(for: address, completion: { (result) in
                switch result {
                case .Success(let localName):
                    name = localName
                case .Error(_):
                    //TODO:
                    print("error")
                }
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            var decimals: BigUInt = BigUInt()
            self.tokensUtilService.decimals(for: address, completion: { (result) in
                switch result {
                case .Success(let localdecimals):
                    decimals = localdecimals
                case .Error(_):
                    //TODO:
                    print("error")
                }
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            var symbol: String = ""
            self.tokensUtilService.symbol(for: address, completion: { (result) in
                switch result {
                case .Success(let localsymbol):
                    symbol = localsymbol
                case .Error( _):
                    //TODO:
                    print("error")
                }
                dispatchGroup.leave()
            })
            
            dispatchGroup.notify(queue: .main) {
                guard !name.isEmpty, !symbol.isEmpty else {
                    completion(SendEth721Result.Error(CustomTokenError.undefinedError))
                    return
                }
                completion(SendEth721Result.Success(ERC721TokenModel(name: name,
                                                                 address: address,
                                                                 decimals: decimals.description,
                                                                 symbol: symbol,
                                                                 isSelected: false)))
                
            }
        }
    }
    
    func searchForCustomToken(with address: String, completion: @escaping (SendEth721Result<ERC721TokenModel>) -> Void) {
        do {
            try self.db.operation { (context, save) in
                if let token = try context.fetch(FetchRequest<ERC721Token>().filtered(with: NSPredicate(format: "address == %@ || name CONTAINS[c] %@ || symbol CONTAINS[c] %@ && isSelected  == %@", address, address, address, NSNumber(value: false)))).first {
                    DispatchQueue.main.async {
                        completion(SendEth721Result.Success(ERC721TokenModel(name: token.name ?? "",
                                                                         address: token.address ?? "",
                                                                         decimals: token.decimals ?? "",
                                                                         symbol: token.symbol ?? "",
                                                                         isSelected: false)))
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        self.makeOnlineSearchToken(with: address, completion: completion)
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                
                self.makeOnlineSearchToken(with: address, completion: completion)
            }
        }
        
    }
    
    func getTokensList(with searchString: String, completion: @escaping (SendEth721Result<[ERC721TokenModel]>) -> Void) {
        
        var tokensList: [ERC721TokenModel] = []
        do {
            try db.operation({ (context, save) in
                let tokens = try context.fetch(FetchRequest<ERC721Token>().filtered(with: NSPredicate(format: "address CONTAINS[c] %@ || name CONTAINS[c] %@ || symbol CONTAINS[c] %@ && isSelected  == %@", searchString, searchString, searchString, NSNumber(value: false))))
                if tokens.count != 0 {
                    DispatchQueue.main.async {
                        for token in tokens {
                            let tokenModel = ERC721TokenModel(name: token.name ?? "",
                                                             address: token.address ?? "",
                                                             decimals: token.decimals ?? "",
                                                             symbol: token.symbol ?? "",
                                                             isSelected: false)
                            tokensList.append(tokenModel)
                        }
                        completion(SendEth721Result.Success(tokensList))
                        return
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.getOnlineTokensList(with: searchString, completion: completion)
                    }
                }
            })
        } catch {
            DispatchQueue.main.async {
                self.getOnlineTokensList(with: searchString, completion: completion)
            }
        }
        
    }
    
    private func getOnlineTokensList(with address: String, completion: @escaping (SendEth721Result<[ERC721TokenModel]>) -> Void) {
        
        guard let _ = EthereumAddress(address) else {
            completion(SendEth721Result.Error(CustomTokenError.undefinedError))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            var name: String = ""
            self.tokensUtilService.name(for: address, completion: { (result) in
                switch result {
                case .Success(let localName):
                    name = localName
                case .Error(_):
                    //TODO:
                    print("error")
                }
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            var decimals: BigUInt = BigUInt()
            self.tokensUtilService.decimals(for: address, completion: { (result) in
                switch result {
                case .Success(let localdecimals):
                    decimals = localdecimals
                case .Error(_):
                    //TODO:
                    print("error")
                }
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            var symbol: String = ""
            self.tokensUtilService.symbol(for: address, completion: { (result) in
                switch result {
                case .Success(let localsymbol):
                    symbol = localsymbol
                case .Error( _):
                    //TODO:
                    print("error")
                }
                dispatchGroup.leave()
            })
            
            dispatchGroup.notify(queue: .main) {
                guard !name.isEmpty, !symbol.isEmpty else {
                    completion(SendEth721Result.Error(CustomTokenError.undefinedError))
                    return
                }
                completion(SendEth721Result.Success([ERC721TokenModel(name: name,
                                                                  address: address,
                                                                  decimals: decimals.description,
                                                                  symbol: symbol,
                                                                  isSelected: false)]))
                
            }
        }
    }
    
    
    let db: CoreDataDefaultStorage
    init() {
        // TODO: add eth by default
        db = DBStorage.db
    }
    
    func deleteToken(with address: String) {
        do {
            try self.db.operation { (context, save) in
                if let token = try context.fetch(FetchRequest<ERC721Token>().filtered(with: NSPredicate(format: "address == %@", address))).first {
                    token.isAdded = false
                }
                save()
            }
        } catch {
            //TODO: There was an error in the operation
        }
    }
    
    let tokensUtilService: UtilTransactionsService = CustomTokenUtilsServiceImplementation()
    
    // TODO: I'm not sure how it'll be used
    func selectedERC721Token() -> ERC721TokenModel {
        // TODO: Add check, that this token can work together with selected network
        guard let token = try! db.fetch(FetchRequest<ERC721Token>().filtered(with: NSPredicate(format: "isSelected == %@", NSNumber(value: true)))).first else {
            return etherModel()
        }
        return ERC721TokenModel(name: token.name ?? "",
                               address: token.address ?? "",
                               decimals: token.decimals ?? "",
                               symbol: token.symbol ?? "",
                               isSelected: token.isSelected)
    }
    
    func updateSelectedToken(to token: String, completion: (() -> Void)? = nil) {
        if token.isEmpty {
            resetSelectedToken()
            DispatchQueue.main.async {
                completion?()
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: DataChangeNotifications.didChangeToken.notificationName(), object: self, userInfo: ["token": token])
            }
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.db.operation { (context, save) in
                    
                    guard let newSelectedToken = try context.fetch(FetchRequest<ERC721Token>().filtered(with: "address", equalTo: token)).first else {
                        DispatchQueue.main.async {
                            completion?()
                        }
                        return
                    }
                    guard let oldSelectedToken = try context.fetch(FetchRequest<ERC721Token>().filtered(with: NSPredicate(format: "isSelected == %@", NSNumber(value: true)))).first else {
                        newSelectedToken.isSelected = true
                        save()
                        DispatchQueue.main.async {
                            completion?()
                        }
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: DataChangeNotifications.didChangeToken.notificationName(), object: self, userInfo: ["token": token])
                        }
                        return
                    }
                    oldSelectedToken.isSelected = false
                    newSelectedToken.isSelected = true
                    save()
                    DispatchQueue.main.async {
                        completion?()
                    }
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: DataChangeNotifications.didChangeToken.notificationName(), object: self, userInfo: ["token": token])
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion?()
                }
                //TODO: There was an error in the operation
            }
            
        }
    }
    
    let networksService = NetworksServiceImplementation()
    func availableTokensList() -> [ERC721TokenModel]? {
        let selectedNetworkURL = networksService.preferredNetwork().fullNetworkUrl.absoluteString
        let networks = try! db.fetch(FetchRequest<ERC721Token>().filtered(with: NSPredicate(format:"networkURL == %@ && isAdded == %@", selectedNetworkURL, NSNumber(value: true))))
        
        let listOfNetworks = [etherModel()] + networks.map { (token) -> ERC721TokenModel in
            return ERC721TokenModel(name: token.name ?? "",
                                   address: token.address ?? "",
                                   decimals: token.decimals ?? "",
                                   symbol: token.symbol ?? "",
                                   isSelected: token.isSelected)
        }
        return listOfNetworks
    }
    
    private func etherModel() -> ERC721TokenModel {
        let isEtherSelected = try! db.fetch(FetchRequest<ERC721Token>().filtered(with: NSPredicate(format: "isSelected == %@", NSNumber(value: true)))).isEmpty
        
        return ERC721TokenModel(name: "Ether", address: "", decimals: "18", symbol: "Eth", isSelected: isEtherSelected)
    }
    
    func updateConversions() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let availableTokens = self.availableTokensList() {
                for token in availableTokens {
                    self.conversionService.updateConversionRate(for: token.symbol.uppercased()) { (rate) in
                        if token == availableTokens.last! {
                            NotificationCenter.default.post(name: ReceiveRatesNotification.receivedAllRates.notificationName(), object: self, userInfo: nil)
                        }
                    }
                }
            }
        }
        
    }
    
    func getNewConversion(for token: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.conversionService.updateConversionRate(for: token.uppercased()) { (rate) in
                NotificationCenter.default.post(name: ReceiveRatesNotification.receivedAllRates.notificationName(), object: self, userInfo: nil)
            }
        }
}


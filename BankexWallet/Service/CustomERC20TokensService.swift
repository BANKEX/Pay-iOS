//
//  CustomERC20TokensService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 3/14/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import SugarRecord
import BigInt
import web3swift




class DBStorage {
    static let db: CoreDataDefaultStorage = {
        let store = CoreDataStore.named("BankexWallet")
        let bundle = Bundle.main
        let model = CoreDataObjectModel.merged([bundle])
        let ldb = try! CoreDataDefaultStorage(store: store, model: model)
        return ldb
    }()
}

protocol CustomERC20TokensService {
    func addNewCustomToken(with address: String,
                           name: String,
                           decimals: String,
                           symbol: String)
    
    func searchForCustomToken(with address: String,
                              completion: @escaping (SendEthResult<ERC20TokenModel>) -> Void)
    
    func getTokensList(with address: String, completion: @escaping (SendEthResult<[ERC20TokenModel]>) -> Void)
    
    func selectedERC20Token() -> ERC20TokenModel
    
    func updateSelectedToken(to token: String, completion: (() -> Void)? )
    
    func deleteToken(with address: String)
    
    func availableTokensList() -> [ERC20TokenModel]?
    
    func resetSelectedToken()
    
    func updateConversions()
    
    func getNewConversion(for token: String)
}


class CustomERC20TokensServiceImplementation: CustomERC20TokensService {
    
    let conversionService = FiatServiceImplementation.service
    
    func resetSelectedToken() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.db.operation { (context, save) in
                    guard let oldSelectedToken = try context.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "isSelected == %@", NSNumber(value: true)))).first else {
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
                var newToken: ERC20Token
                if let token = try context.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "address == %@", address))).first {
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
    
    
    private func makeOnlineSearchToken(with address: String, completion: @escaping (SendEthResult<ERC20TokenModel>) -> Void) {
        
        guard let _ = EthereumAddress(address) else {
            completion(SendEthResult.Error(CustomTokenError.undefinedError))
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
                case .Error(let error):
                    DispatchQueue.main.async {
                        completion(SendEthResult.Error(error))
                    }
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
                case .Error(let error):
                    DispatchQueue.main.async {
                        completion(SendEthResult.Error(error))
                    }
                }
                dispatchGroup.leave()
            })
            
            dispatchGroup.notify(queue: .main) {
                guard !name.isEmpty, !symbol.isEmpty else {
                    completion(SendEthResult.Error(CustomTokenError.undefinedError))
                    return
                }
                completion(SendEthResult.Success(ERC20TokenModel(name: name,
                                                                 address: address,
                                                                 decimals: decimals.description,
                                                                 symbol: symbol,
                                                                 isSelected: false)))
                
            }
        }
    }
    
    func searchForCustomToken(with address: String, completion: @escaping (SendEthResult<ERC20TokenModel>) -> Void) {
        do {
            try self.db.operation { (context, save) in
                if let token = try context.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "address == %@ || name CONTAINS[c] %@ || symbol CONTAINS[c] %@ && isSelected  == %@", address, address, address, NSNumber(value: false)))).first {
                    DispatchQueue.main.async {
                        completion(SendEthResult.Success(ERC20TokenModel(name: token.name ?? "",
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
    
    func getTokensList(with searchString: String, completion: @escaping (SendEthResult<[ERC20TokenModel]>) -> Void) {
        var tokensList: [ERC20TokenModel] = []
        DispatchQueue.global().async {
            do {
                try self.db.operation({ (context, save) in
                    let tokens = try context.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "address CONTAINS[c] %@ || name CONTAINS[c] %@ || symbol CONTAINS[c] %@ && isSelected  == %@", searchString, searchString, searchString, NSNumber(value: false))))
                    if tokens.count != 0 {
                        DispatchQueue.main.async {
                            for token in tokens {
                                let tokenModel = ERC20TokenModel(name: token.name ?? "",
                                                                 address: token.address ?? "",
                                                                 decimals: token.decimals ?? "",
                                                                 symbol: token.symbol ?? "",
                                                                 isSelected: false,isAdded: token.isAdded)
                                tokensList.append(tokenModel)
                            }
                            completion(SendEthResult.Success(tokensList))
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
    }
    
    private func getOnlineTokensList(with address: String, completion: @escaping (SendEthResult<[ERC20TokenModel]>) -> Void) {
        
        guard let _ = EthereumAddress(address) else {
            completion(SendEthResult.Error(CustomTokenError.undefinedError))
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
                case .Error(let error):
                    DispatchQueue.main.async {
                        completion(SendEthResult.Error(error))
                    }
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
                case .Error( let error):
                    DispatchQueue.main.async {
                        completion(SendEthResult.Error(error))
                    }
                }
                dispatchGroup.leave()
            })
            
            dispatchGroup.notify(queue: .main) {
                guard !name.isEmpty, !symbol.isEmpty else {
                    completion(SendEthResult.Error(CustomTokenError.undefinedError))
                    return
                }
                completion(SendEthResult.Success([ERC20TokenModel(name: name,
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
                if let token = try context.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "address == %@", address))).first {
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
    func selectedERC20Token() -> ERC20TokenModel {
        // TODO: Add check, that this token can work together with selected network
        guard let token = try! db.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "isSelected == %@", NSNumber(value: true)))).first else {
            return etherModel()
        }
        return ERC20TokenModel(name: token.name ?? "",
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
                    
                    guard let newSelectedToken = try context.fetch(FetchRequest<ERC20Token>().filtered(with: "address", equalTo: token)).first else {
                        DispatchQueue.main.async {
                            completion?()
                        }
                        return
                    }
                    guard let oldSelectedToken = try context.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "isSelected == %@", NSNumber(value: true)))).first else {
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
    func availableTokensList() -> [ERC20TokenModel]? {
        let selectedNetworkURL = networksService.preferredNetwork().fullNetworkUrl.absoluteString
        let networks = try! db.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format:"networkURL == %@ && isAdded == %@", selectedNetworkURL, NSNumber(value: true))))
        
        let listOfNetworks = [etherModel()] + networks.map { (token) -> ERC20TokenModel in
            return ERC20TokenModel(name: token.name ?? "",
                                   address: token.address ?? "",
                                   decimals: token.decimals ?? "",
                                   symbol: token.symbol ?? "",
                                   isSelected: token.isSelected,isAdded: token.isAdded)
            
        }
        return listOfNetworks
    }
    
    private func etherModel() -> ERC20TokenModel {
        let isEtherSelected = try! db.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "isSelected == %@", NSNumber(value: true)))).isEmpty
        
        return ERC20TokenModel(name: "Ether", address: "", decimals: "18", symbol: "Eth", isSelected: isEtherSelected)
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
    
}

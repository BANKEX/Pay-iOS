//
//  CustomERC20TokensService.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina (Agoda) on 3/14/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import SugarRecord
import BigInt

protocol CustomERC20TokensService {
    func addNewCustomToken(with address: String,
                           completion: @escaping (SendEthResult<ERC20Token>) -> Void)
    
    func selectedERC20Token() -> ERC20Token?
    
    func updateSelectedToken(to token: String)
    
    func deleteToken(with name: String)
}


class CustomERC20TokensServiceImplementation: CustomERC20TokensService {
    
    let db: CoreDataDefaultStorage
    init() {
        let store = CoreDataStore.named("BankexWallet")
        let bundle = Bundle.main
        let model = CoreDataObjectModel.merged([bundle])
        db = try! CoreDataDefaultStorage(store: store, model: model)
        // TODO: add eth by default
    }
    
    func deleteToken(with name: String) {
        
    }
    
    let tokensUtilService: UtilTransactionsService = UtilTransactionsServiceImplementation()
    func addNewCustomToken(with address: String, completion: @escaping (SendEthResult<ERC20Token>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            self.tokensUtilService.getBalance(for: address, completion: { (result) in
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            var name: String = ""
            self.tokensUtilService.name(completion: { (result) in
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
            self.tokensUtilService.decimals(completion: { (result) in
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
            self.tokensUtilService.symbol(completion: { (result) in
                switch result {
                case .Success(let localsymbol):
                    symbol = localsymbol
                case .Error( _):
                    //TODO:
                    print("error")
                }
                dispatchGroup.leave()
            })
            
            dispatchGroup.notify(queue: .global()) {
                do {
                    try self.db.operation { (context, save) in
                        let newToken: ERC20Token = try context.new()
                        newToken.address = address
                        newToken.name = name
                        newToken.symbol = symbol
                        newToken.decimals = decimals.description
                        try context.insert(newToken)
                        save()
                    }
                } catch {
                    //TODO: There was an error in the operation
                }
                DispatchQueue.main.async {
                    guard let newToken = try! self.db.fetch(FetchRequest<ERC20Token>().filtered(with: "address", in: [address])).first else {
                        completion(SendEthResult.Error(SendEthErrors.invalidAmountFormat))
                        return
                    }
                    completion(SendEthResult.Success(newToken))
                    
                }
            }
        }
    }
    
    // TODO: I'm not sure how it'll be used
    func selectedERC20Token() -> ERC20Token? {
        guard let selectedToken = try! db.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "isSelected == %@", argumentArray: [true]))).first else {
            return nil
        }
        return selectedToken
    }
    
    func updateSelectedToken(to token: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.db.operation { (context, save) in
                    guard let newSelectedToken = try self.db.fetch(FetchRequest<ERC20Token>().filtered(with: "address", equalTo: token)).first else {
                        return
                    }
                    guard let oldSelectedToken = try self.db.fetch(FetchRequest<ERC20Token>().filtered(with: NSPredicate(format: "isSelected == %@", argumentArray: [true]))).first else {
                        return
                    }
                    newSelectedToken.isSelected = true
                    oldSelectedToken.isSelected = false
                    save()
                }
            } catch {
                //TODO: There was an error in the operation
            }

        }
    }
    
    
}

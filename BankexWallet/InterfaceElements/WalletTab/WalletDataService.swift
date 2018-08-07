//
//  WalletDataService.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 23.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

class WalletData {
    
    let service: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    var etherToken: ERC20TokenModel?
    var tokens = [ERC20TokenModel]()
    var sendEthService: SendEthService!
    var transactionsToShow = [ETHTransactionModel]()
    
    func update(callback: @escaping (ERC20TokenModel?,[ETHTransactionModel], [ERC20TokenModel]) -> Void) {
        
        //1 - ether token
        //2 - transactions
        //3 - available tokens
        callback(service.availableTokensList()?.first,
                 putTransactionsInfoIntoItemsArray(),
                 updateAvailableTokens())
        
    }
    
    func putTransactionsInfoIntoItemsArray() -> [ETHTransactionModel] {
        sendEthService = service.selectedERC20Token().address.isEmpty ?
            SendEthServiceImplementation() :
            ERC20TokenContractMethodsServiceImplementation()
        if let firstThree = sendEthService.getAllTransactions()?.prefix(3) {
            transactionsToShow = Array(firstThree)
        }
        return transactionsToShow
    }
    
    func updateAvailableTokens() -> [ERC20TokenModel] {
        tokens = service.availableTokensList()!
        tokens.remove(at: 0) //remove eth
        return tokens
    }
}

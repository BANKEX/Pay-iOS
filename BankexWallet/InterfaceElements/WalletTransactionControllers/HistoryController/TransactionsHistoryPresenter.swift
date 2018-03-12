//
//  TransactionsHistoryPresenter.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/4/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class TransactionsHistoryPresenter: TransactionsHistoryViewOutput {
    weak var view: TransactionsHistoryViewInput?
    
    let service: SendEthService = SendEthServiceImplementation()
    
    func viewIsReady() {
        //check if any of key exists
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
        guard let _ = keystoreManager?.addresses?.first else {
            view?.showNoKeysAvailableView()
            return
        }
        let objects = service.getAllTransactions()
        guard let obj = objects,  !obj.isEmpty else {
            view?.showEmptyView()
            return
        }
        view?.show(transactions: obj)
    }
}

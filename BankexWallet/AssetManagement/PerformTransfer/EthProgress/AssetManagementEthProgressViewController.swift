//
//  AssetManagementEthProgressViewController.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 29/11/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit
import web3swift

class AssetManagementEthProgressViewController: UIViewController {
    
    var sendTrService:SendTransactionService!
    var amount:String?
    var toAddress:String = ""
    var transactionResult:TransactionSendingResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let amount = amount else { return }
        sendTrService = SendTransactionService(toAddress: toAddress, amount: amount)
        sendTrService.sendTransaction { result in
            switch result {
            case .Success(let transactionResult):
                self.transactionResult = transactionResult
                self.showSuccess()
            case .Error( _):
                self.showFailure()
            }
        }
    }
    
    private func showSuccess() {
        performSegue(withIdentifier: "Success", sender: self)
    }
    
    private func showFailure() {
        performSegue(withIdentifier: "Failure", sender: self)
    }
    
}

extension AssetManagementEthProgressViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? AssetManagementEthSuccessViewController {
            viewController.trResult = transactionResult
        }
    }
    
}

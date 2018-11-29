//
//  AssetManagementEthProgressViewController.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 29/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class AssetManagementEthProgressViewController: UIViewController {
    
    var sendTrService:SendTransactionService!
    var amount:String?
    var toAddress:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let amount = amount else { return }
        sendTrService = SendTransactionService(toAddress: toAddress, amount: amount)
        sendTrService.sendTransaction { result in
            switch result {
            case .Success(let transactionResult):
                break
            case .Error(let error):
                break
            }
        }
    }
    
    private func showSuccess() {
        performSegue(withIdentifier: "Success", sender: self)
    }
    
}

extension AssetManagementEthProgressViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? AssetManagementEthSuccessViewController {
            
        }
    }
    
}

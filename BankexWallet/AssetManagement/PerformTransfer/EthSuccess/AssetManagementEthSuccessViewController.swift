//
//  AssetManagementEthSuccessViewController.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 29/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class AssetManagementEthSuccessViewController: UIViewController {
    
    var trResult:TransactionSendingResult?
    
    @IBAction private func finish() {
        performSegue(withIdentifier: "Home", sender: self)
    }
    
    @IBAction func openTransaction() {
        guard let _ = trResult?.hash else { return }
        performSegue(withIdentifier: "Browser", sender: self)
    }
}

extension AssetManagementEthSuccessViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let browser = segue.destination as? AssetManagementBrowserViewController,
            let trHash = trResult?.hash {
            browser.link = URL(string: "https://etherscan.io/tx/\(trHash)")!
        }
    }
}

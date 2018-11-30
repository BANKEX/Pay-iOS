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
        print("openTransaction")
        guard let trHash = trResult?.hash else { return }
        
        let pageURL = URL(string: "https://etherscan.io/tx/\(trHash)")!
        
        UIApplication.shared.openURL(pageURL)
    }
    
}

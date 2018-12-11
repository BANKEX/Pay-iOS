//
//  AssetManagementEthSuccessViewController.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 29/11/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
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
    
    private func transactionLinkURL(for result: TransactionSendingResult?) -> URL? {
        guard let hash = result?.hash else { return nil }
        
        return URL(string: "https://etherscan.io/tx/\(hash)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let browser = segue.destination as? AssetManagementBrowserViewController {
            browser.link = transactionLinkURL(for: trResult)
        }
        
        if let linksViewController = segue.destination as? AssetManagementLinksViewController {
            linksViewController.transactionLinkURL = transactionLinkURL(for: trResult)
        }
    }
}

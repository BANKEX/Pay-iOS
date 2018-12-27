//
//  AssetManagementEthSuccessViewController.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 29/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift
import SafariServices

class AssetManagementEthSuccessViewController: UIViewController {
    
    var trResult:TransactionSendingResult?
    
    @IBAction private func finish() {
        performSegue(withIdentifier: "Home", sender: self)
    }
    
    @IBAction func openTransaction() {
        guard let _ = trResult?.hash else { return }
        
        let url = transactionLinkURL(for: trResult)!
        present(SFSafariViewController(assetManagementUrl: url), animated: true, completion:  nil)
    }
}

extension AssetManagementEthSuccessViewController {
    
    private func transactionLinkURL(for result: TransactionSendingResult?) -> URL? {
        guard let hash = result?.hash else { return nil }
        
        return URL(string: "https://etherscan.io/tx/\(hash)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let linksViewController = segue.destination as? AssetManagementLinksViewController {
            linksViewController.transactionLinkURL = transactionLinkURL(for: trResult)
        }
    }
}

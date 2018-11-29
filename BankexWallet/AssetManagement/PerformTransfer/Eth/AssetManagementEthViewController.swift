//
//  AssetManagementPerformEthTransferViewController.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 28/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class AssetManagementEthViewController: UIViewController {
    
    @IBOutlet var walletNameLabel: UILabel!
    @IBOutlet var walletAddressLabel: UILabel!
    @IBOutlet var walletBalanceLabel: UILabel!
    
    @IBAction func finish() {
        performSegue(withIdentifier: "Home", sender: self)
    }
    
}

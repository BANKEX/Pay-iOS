//
//  AssetManagementEthFailureViewController.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 29/11/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class AssetManagementEthFailureViewController: UIViewController {
    
    @IBAction private func finish() {
        performSegue(withIdentifier: "Home", sender: self)
    }
    
}

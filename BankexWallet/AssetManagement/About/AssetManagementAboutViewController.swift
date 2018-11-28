//
//  AssetManagementAboutViewController.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 28/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class AssetManagementAboutViewController: UIViewController {
    
    @IBAction func finish() {
        performSegue(withIdentifier: "Home", sender: self)
    }
    
}

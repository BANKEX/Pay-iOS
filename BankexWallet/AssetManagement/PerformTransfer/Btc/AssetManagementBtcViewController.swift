//
//  AssetManagementBtcViewController.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 29/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class AssetManagementBtcViewController: UIViewController {
    
    @IBAction func finish() {
        performSegue(withIdentifier: "Home", sender: self)
    }
    
}

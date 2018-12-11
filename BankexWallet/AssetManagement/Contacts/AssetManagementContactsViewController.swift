//
//  AssetManagementContactsViewController.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 28/11/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class AssetManagementContactsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: BackButtonView.create(self, action: #selector(finish)))
    }
    
    @objc func finish() {
        performSegue(withIdentifier: "Home", sender: self)
    }
    
}

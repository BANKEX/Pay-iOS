//
//  GenericImportViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class GenericImportViewController: UIViewController {

    @IBOutlet weak var segmentedControl:UISegmentedControl! //I dont know how to name
    @IBOutlet weak var privateKeyContainer:UIView!
    @IBOutlet weak var passphraseContainer:UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Importing Wallet"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    
    @IBAction func segmentedControlerTapped(_ sender:UISegmentedControl) {
        updateUI()
    }
    
    func updateUI() {
        if segmentedControl.selectedSegmentIndex == 0 {
            privateKeyContainer.isHidden = false
            passphraseContainer.isHidden = true
        }else {
            privateKeyContainer.isHidden = true
            passphraseContainer.isHidden = false
        }
    }

    

}

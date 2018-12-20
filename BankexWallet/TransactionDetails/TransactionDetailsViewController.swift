//
//  TransactionDetailsViewController.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 19/12/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class TransactionDetailsViewController: UIViewController {
    
    var transaction: ETHTransactionModel?
    
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var txHashLabel: UILabel!
    
    @IBAction func tapBack(_ sender: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapShare(_ sender: UIButton) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
    }

    private func configureNavBar() {
        navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarView?.backgroundColor = UIDevice.isIpad ? .white : .disableColor
        UIApplication.shared.statusBarStyle = UIDevice.isIpad ? .default : .`default`
    }

}

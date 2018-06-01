//
//  WalletCreationTypeController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/3/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class WalletCreationTypeController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    var isBackButtonHidden: Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (navigationController?.viewControllers.count ?? 0) > 1 {
            backButton.isHidden = false
        }
        if let isHidded = isBackButtonHidden {
            backButton.isHidden = isHidded
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let controller = segue.destination as? GenericWalletCreationContainer else {
            return
        }
        controller.walletCreationMode = segue.identifier == "importWallet" ? WalletKeysMode.importKey : WalletKeysMode.createKey
    }
 
    
    
    @IBAction func unwind(segue:UIStoryboardSegue) { }

}

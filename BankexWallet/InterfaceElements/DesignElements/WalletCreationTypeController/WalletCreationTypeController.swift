//
//  WalletCreationTypeController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/3/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class WalletCreationTypeController: UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? GenericWalletCreationContainer else {
            return
        }
        controller.walletCreationMode = segue.identifier == "importWallet" ? WalletKeysMode.importKey : WalletKeysMode.createKey
    }
 
    
    
    @IBAction func unwind(segue:UIStoryboardSegue) { }

}

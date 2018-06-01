//
//  ERC20StandartViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 01/06/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ERC20StandartViewController: UIViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? WalletCreationTypeController {
            destination.isBackButtonHidden = true
        }
    }

}

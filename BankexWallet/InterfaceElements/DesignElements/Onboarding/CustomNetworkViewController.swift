//
//  CustomNetworkViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 01/06/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class CustomNetworkViewController: UIViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destionation = segue.destination as? WalletCreationTypeController {
            destionation.isBackButtonHidden = true
        }
    }

}

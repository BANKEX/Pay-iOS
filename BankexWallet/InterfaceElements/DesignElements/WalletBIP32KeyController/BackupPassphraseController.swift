//
//  BackupPassphraseController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/16/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class BackupPassphraseController: UIViewController {

    @IBOutlet weak var passphraseLabel: UILabel!
    var passphraseToShow: String?
    let router: WalletCreationRouter = WalletCreationTypeRouterImplementation()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        passphraseLabel.text = passphraseToShow
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        router.exitFromTheScreen()
    }
    
    @IBAction func copyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = passphraseToShow
    }
}

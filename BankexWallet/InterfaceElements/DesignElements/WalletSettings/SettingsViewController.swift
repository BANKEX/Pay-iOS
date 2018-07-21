//
//  SettingsViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 21.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit


class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var nameWalletLabel:UILabel!
    @IBOutlet weak var nameNetworkLabel:UILabel!
    
    
    
    let managerReferences = ManagerReferences()
    let walletService = SingleKeyServiceImplementation()
    let networkService = NetworksServiceImplementation()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    

    
    func updateUI() {
        guard let selectedWallet = walletService.selectedWallet() else { return  }
        nameWalletLabel.text = selectedWallet.name ?? selectedWallet.address
        nameNetworkLabel.text = networkService.preferredNetwork().networkName ?? networkService.preferredNetwork().fullNetworkUrl.absoluteString
    }

    
    
    
}

//
//  WalletsViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 22.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class WalletsViewController: UIViewController {
    
    @IBOutlet weak var tableView:UITableView!
    
    let service: GlobalWalletsService = HDWalletServiceImplementation()
    var listWallets = [HDKey]()
//    var selectedWallet:HDKey? {
//        return service KeyWalletModel
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Wallets"
        tableView.dataSource = self
        tableView.delegate = self
        listWallets = (service.fullHDKeysList() ?? [HDKey]()) + (service.fullListOfSingleEthereumAddresses() ?? [HDKey]())
    }

    

}

extension WalletsViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : listWallets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WalletCell.identifier, for: indexPath) as! WalletCell
        switch indexPath.section {
        //case 0:
           // cell.configure(wallet: selectedWallet)
        case 1:
            let currentWallet = listWallets[indexPath.row]
            cell.configure(wallet: currentWallet)
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "CHOOSE A WALLET..." : ""
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
}

extension WalletsViewController:UITableViewDelegate {
    
}

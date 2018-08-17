//
//  WalletsDataSource.swift
//  BankexWallet
//
//  Created by Vladislav on 23.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

extension WalletsViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return WalletsSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == WalletsSections.CurrentWallet.rawValue ? 1 : listWallets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: WalletCell.identifier, for: indexPath) as! WalletCell
        cell.delegate = self
        switch indexPath.section {
        case WalletsSections.CurrentWallet.rawValue:
            cell.configure(wallet: selectedWallet!)
        case WalletsSections.RestWallets.rawValue:
            let currentWallet = listWallets[indexPath.row]
            cell.configure(wallet: currentWallet)
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == WalletsSections.RestWallets.rawValue ? "CHOOSE A WALLET..." : "CURRENT WALLET"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
}

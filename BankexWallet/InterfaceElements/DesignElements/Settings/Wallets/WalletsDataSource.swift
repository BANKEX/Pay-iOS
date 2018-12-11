//
//  WalletsDataSource.swift
//  BankexWallet
//
//  Created by Vladislav on 23.07.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

extension WalletsViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return WalletsSections.allCases.count
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView()
        if WalletsSections.CurrentWallet.rawValue == section {
            headerView.title = NSLocalizedString("CurrentWallet", comment: "")
        }else {
            headerView.title = NSLocalizedString("ChooseWallet", comment: "")
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
}

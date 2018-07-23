//
//  UITableViewDataSource.swift
//  BankexWallet
//
//  Created by Vladislav on 22.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

extension NetworksViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return listNetworks.count
        case 2: return listNetworks.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "CHOOSE A NETWORK..."
        }else if section == 2 && listCustomNetworks.count > 0 {
            return "CUSTOM NETWORK"
        }else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.textLabel?.text = selectedNetwork.networkName ?? selectedNetwork.fullNetworkUrl.absoluteString
        }else if indexPath.section == 1 {
            cell.textLabel?.text = listNetworks[indexPath.row].networkName
        }else if indexPath.section == 2 {
            if listCustomNetworks.count > 0 {
                cell.textLabel?.text = listCustomNetworks[indexPath.row].networkName
            }else {
                let indexSet = IndexSet(integer: indexPath.section)
                tableView.deleteSections(indexSet, with: .none)
                tableView.reloadData()  // change leter
            }
        }
        return cell
    }
}

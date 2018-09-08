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
        return NetworksSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case NetworksSections.CurrentNetwork.rawValue: return 1
        case NetworksSections.DefaultNetwork.rawValue: return listNetworks.count
        case NetworksSections.CustomNetwork.rawValue: return listCustomNetworks.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == NetworksSections.DefaultNetwork.rawValue {
            return NSLocalizedString("ChooseNetwork", comment: "")
        }else if section == NetworksSections.CustomNetwork.rawValue && listCustomNetworks.count > 0 {
            return "CUSTOM NETWORK"
        }else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.section == NetworksSections.CurrentNetwork.rawValue && indexPath.row == 0 {
            cell.textLabel?.text = selectedNetwork.networkName ?? selectedNetwork.fullNetworkUrl.absoluteString
        }else if indexPath.section == NetworksSections.DefaultNetwork.rawValue{
            cell.textLabel?.text = listNetworks[indexPath.row].networkName
        }else if indexPath.section == NetworksSections.CustomNetwork.rawValue{
            if listCustomNetworks.count > 0 {
                cell.textLabel?.text = listCustomNetworks[indexPath.row].networkName
            }
        }
        return cell
    }
}


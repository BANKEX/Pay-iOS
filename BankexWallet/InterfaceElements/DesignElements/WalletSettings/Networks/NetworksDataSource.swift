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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case NetworksSections.CurrentNetwork.rawValue: return 1
        case 1:
            return isFromDeveloper ? listCustomNetworks.count : listNetworks.count
        default: return 0
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView()
        if section == 0 {
            headerView.title = "CURRENT NETWORK"
        }else {
            if isFromDeveloper && listCustomNetworks.count == 0 {
                headerView.textColor = .clear
            }
            headerView.title = isFromDeveloper ? "CUSTOM NETWORKS" : "DEFAULT NETWORKS"
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54.0
    }
}


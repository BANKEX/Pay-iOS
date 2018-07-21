//
//  NetworksViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 21.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class NetworksViewController: UIViewController {
    
    @IBOutlet weak var tableView:UITableView!
    
    
    
    
    var selectedNetwork:CustomNetwork {
        return networkService.preferredNetwork()
    }
    let networkService = NetworksServiceImplementation()
    var listNetworks:[CustomNetwork]!
    var listCustomNetworks:[CustomNetwork] {
        var array = listNetworks[4...]
        var arr = Array(array)
        return arr
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        listNetworks = networkService.currentNetworksList()
        title = "Connection"
    }
    
    
    
    
    
    
}

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
        }else if section == 2 {
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

extension NetworksViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

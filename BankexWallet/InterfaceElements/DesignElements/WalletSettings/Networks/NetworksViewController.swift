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
        var array = Array(listNetworks[4...])
        return array
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        listNetworks = networkService.currentNetworksList()
        title = "Connection"
        navigationController?.navigationBar.isHidden = false
    }

    
    
}


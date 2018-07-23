//
//  NetworksViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 21.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol NetworkDelegate:class {
    func didTapped(with network:CustomNetwork)
}

class NetworksViewController: UIViewController {
    
    @IBOutlet weak var tableView:UITableView!
    
    
    weak var delegate:NetworkDelegate?
    
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
        self.listNetworks = self.networkService.currentNetworksList()
        navigationItem.title = "Connection"
        navigationController?.navigationBar.isHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNetworkTapped(_:)))
        
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeNetwork.notificationName(), object: nil, queue: nil) { (_) in
            self.tableView.reloadData()
        }
    }
    
    
    @objc func createNetworkTapped(_ sender:UIButton) {
        performSegue(withIdentifier: "createNetworkSegue", sender: self)
    }
    
}


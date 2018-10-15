//
//  NetworksViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 21.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import Foundation

protocol CounableProtocol {
    static var count:Int { get }
}

protocol NetworkDelegate:class {
    func didTapped(with network:CustomNetwork)
}

class NetworksViewController: BaseViewController {
    
    @IBOutlet weak var tableView:UITableView!
    
    
    enum NetworksSections:Int,CaseIterable {
        case CurrentNetwork = 0,DefaultNetwork,CustomNetwork
    }
    
    weak var delegate:NetworkDelegate?
    
    var selectedNetwork:CustomNetwork {
        return networkService.preferredNetwork()
    }
    var isFromDeveloper = false
    let networkService = NetworksServiceImplementation()
    var listNetworks:[CustomNetwork]!
    var listCustomNetworks:[CustomNetwork] {
        return Array(listNetworks[4...])
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        self.listNetworks = self.networkService.currentNetworksList()
        tableView.tableFooterView = HeaderView()
        tableView.backgroundColor = WalletColors.bgMainColor
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeNetwork.notificationName(), object: nil, queue: nil) { (_) in
            self.tableView.reloadData()
        }
        
    }
    
    func hideAddBtn() {
        navigationItem.rightBarButtonItem = nil
    }
    
    func configure() {
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.title = isFromDeveloper ? NSLocalizedString("CustomNetworks", comment: "") : NSLocalizedString("Network", comment: "")
        if !isFromDeveloper {
            hideAddBtn()
        }else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNetworkTapped(_:)))
        }
    }
    
    
    @objc func createNetworkTapped(_ sender:UIButton) {
        performSegue(withIdentifier: "createNetworkSegue", sender: self)
    }
    
}




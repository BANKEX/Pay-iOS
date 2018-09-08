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

class NetworksViewController: UIViewController {
    
    @IBOutlet weak var tableView:UITableView!
    
    
    enum NetworksSections:Int,CounableProtocol {
        case CurrentNetwork = 0,DefaultNetwork,CustomNetwork
        
        static let count: Int = {
            var max: Int = 0
            while let _ = NetworksSections(rawValue: max) { max += 1 }
            return max
        }()
    }
    
    weak var delegate:NetworkDelegate?
    
    var selectedNetwork:CustomNetwork {
        return networkService.preferredNetwork()
    }
    let networkService = NetworksServiceImplementation()
    var listNetworks:[CustomNetwork]!
    var listCustomNetworks:[CustomNetwork] {
        return Array(listNetworks[4...])
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        self.listNetworks = self.networkService.currentNetworksList()
        
        
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeNetwork.notificationName(), object: nil, queue: nil) { (_) in
            self.tableView.reloadData()
        }
    }
    
    func configure() {
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.title = NSLocalizedString("Connection", comment: "Connection")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNetworkTapped(_:)))
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    @objc func createNetworkTapped(_ sender:UIButton) {
        performSegue(withIdentifier: "createNetworkSegue", sender: self)
    }
    
}




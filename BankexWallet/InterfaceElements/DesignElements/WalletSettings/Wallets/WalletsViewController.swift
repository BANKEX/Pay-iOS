//
//  WalletsViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 22.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol WalletsDelegate:class  {
    func didTapped(with wallet:HDKey)
}

class WalletsViewController: UIViewController {
    
    
    @IBOutlet weak var tableView:UITableView!
    
    
    
    
    let service: GlobalWalletsService = HDWalletServiceImplementation()
    var listWallets = [HDKey]()
    var selectedWallet:HDKey? {
        return service.selectedKey()
    }
    weak var delegate:WalletsDelegate?

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        listWallets = (service.fullHDKeysList() ?? [HDKey]()) + (service.fullListOfSingleEthereumAddresses() ?? [HDKey]())
        
        
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeWallet.notificationName(), object: nil, queue: nil) { _ in
            self.tableView.reloadData()
        }
    }
    
    
    
    @objc func goBack(_ sender:UIButton) {
        performSegue(withIdentifier: "backSegue", sender: nil)
    }
    
    func configure() {
        navigationItem.title = "Wallets"
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goBack(_:)))
    }

    

}





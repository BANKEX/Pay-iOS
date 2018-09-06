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

class WalletsViewController: UIViewController, WalletSelectedDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    
    enum WalletsSections:Int,CounableProtocol {
        static var count: Int = {
            var max:Int = 0
            while let _ = WalletsSections(rawValue: max) { max += 1 }
            return max
        }()
        
        case CurrentWallet = 0,RestWallets
    }
    
    
    
    
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
        performSegue(withIdentifier: "showAddWalletVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddWalletVC" {
            guard let destVC = segue.destination as? WalletCreationTypeController else { return }
            destVC.isFromInitial = false
        } else if let walletInfoViewController = segue.destination as? WalletInfoViewController {
            walletInfoViewController.publicAddress = sender as? String
        }
    }
    
    func configure() {
        navigationItem.title = NSLocalizedString("Wallets", comment: "")
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        tableView.dataSource = self
        tableView.delegate = self
        var btn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goBack(_:)))
        btn.accessibilityLabel = "AddBtn"
        navigationItem.rightBarButtonItem = btn
    }
    
    //MARK: - WalletSelectedDelegate
    func didSelectWallet(withAddress address: String) {
        self.performSegue(withIdentifier: "ShowWalletInfo", sender: address)
    }
    
}






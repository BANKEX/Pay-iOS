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

class WalletsViewController: BaseViewController, WalletSelectedDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    
    enum WalletsSections:Int,CaseIterable {
        case CurrentWallet = 0,RestWallets
    }
    
    
    
    let service: HDWalletServiceImplementation = HDWalletServiceImplementation()
    var listWallets = [HDKey]()
    var selectedWallet:HDKey? {
        return service.selectedKey()
    }
    override var navigationBarAppearance: NavigationBarAppearance? {
        return .whiteStyle
    }
    weak var delegate:WalletsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeWallet.notificationName(), object: nil, queue: nil) { _ in
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        splitViewController?.show()
        service.updateSelectedWallet()
        listWallets = (service.fullHDKeysList() ?? [HDKey]()) + (service.fullListOfSingleEthereumAddresses() ?? [HDKey]())
        tableView.reloadData()
    }
    
    
    @objc func goBack(_ sender:UIButton) {
        performSegue(withIdentifier: "showAddWalletVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddWalletVC" {
            guard let destVC = segue.destination as? WalletCreationTypeController else { return }
            destVC.isFromInitial = false
        } else if let walletInfoViewController = segue.destination as? WalletInfoViewController {
            walletInfoViewController.dict = sender as? [String:String]
        }
    }
    
    func configure() {
        navigationItem.title = NSLocalizedString("Wallets", comment: "")
        tableView.dataSource = self
        tableView.delegate = self
        var btn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goBack(_:)))
        btn.accessibilityLabel = "AddBtn"
        navigationItem.rightBarButtonItem = btn
        tableView.backgroundColor = UIColor.bgMainColor
        tableView.tableFooterView = HeaderView()
    }
    
    //MARK: - WalletSelectedDelegate
    func didSelectWallet(withAddress address: String, name: String) {
        let dict = ["addr":address,"name":name]
        self.performSegue(withIdentifier: "ShowWalletInfo", sender: dict)
    }
    

}






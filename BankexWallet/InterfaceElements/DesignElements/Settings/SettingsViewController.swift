//
//  SettingsViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 21.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit


class SettingsViewController: UITableViewController,NetworkDelegate,WalletsDelegate {
    func didTapped(with wallet: HDKey) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func didTapped(with network: CustomNetwork) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBOutlet weak var nameWalletLabel:UILabel!
    @IBOutlet weak var nameNetworkLabel:UILabel!
    
    
    enum SettingsSections:Int,CaseIterable {
        case General = 0,Support,Community,Developer
    }
    
    let managerReferences = ManagerReferences()
    let walletService = SingleKeyServiceImplementation()
    let networkService = NetworksServiceImplementation()
    var selectedSection:Int!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        prepareNavbar()
        tableView.backgroundColor = WalletColors.bgMainColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        walletService.updateSelectedWallet()
        updateUI()
        setupFooter()
    }

    func prepareNavbar() {
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupFooter() {
        tableView.tableFooterView = HeaderView()
    }

    
    func updateUI() {
        guard let selectedWallet = walletService.selectedWallet() else { return  }
        nameWalletLabel.text = selectedWallet.name ?? selectedWallet.address
        nameNetworkLabel.text = networkService.preferredNetwork().networkName ?? networkService.preferredNetwork().fullNetworkUrl.absoluteString
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "networkSegue" {
            let dest = segue.destination as! NetworksViewController
            dest.delegate = self
            dest.isFromDeveloper = selectedSection == SettingsSections.Developer.rawValue ? true : false
        }else if segue.identifier == "walletSegue" {
            let dest = segue.destination as! WalletsViewController
            dest.delegate = self
        }else if let attentionVC = segue.destination as? AttentionViewController {
            attentionVC.isFromDeveloper = true
        }
    }
    
    
}

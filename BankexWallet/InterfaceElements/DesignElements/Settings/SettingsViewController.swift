//
//  SettingsViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 21.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift


class SettingsViewController: UITableViewController {
    
    enum SettingsSections:Int,CaseIterable {
        case  General = 0 ,Support,Community,Developer
    }
    
    
    @IBOutlet weak var nameWalletLabel:UILabel!
    @IBOutlet weak var nameNetworkLabel:UILabel!
    
    
    let managerReferences = ManagerReferences()
    let walletService = SingleKeyServiceImplementation()
    let networkService = NetworksServiceImplementation()
    var selectedSection:Int!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavbar()
        commonSetup()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        walletService.updateSelectedWallet()
        updateUI()
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
    
    private func commonSetup() {
        tableView.backgroundColor = UIColor.bgMainColor
        tableView.tableFooterView = HeaderView()
        if UIDevice.isIpad { tableView.separatorInset.right = 20 }
        tableView.separatorInset.left = UIDevice.isIpad ? 80 : 60
    }
    
    
    private func updateBalance() {
        var utilsService:UtilTransactionsService
        let tokenService = CustomERC20TokensServiceImplementation()
        let selectedToken = tokenService.selectedERC20Token()
        let keyService = SingleKeyServiceImplementation()
        utilsService = selectedToken.address.isEmpty ? UtilTransactionsServiceImplementation() :
            CustomTokenUtilsServiceImplementation()
        guard let selectedAddress = keyService.selectedAddress() else {
            return
        }
        utilsService.getBalance(for: selectedToken.address, address: selectedAddress) { (result) in
            switch result {
            case .Success(let response):
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                DispatchQueue.global(qos: .utility).async {
                    let formattedAmount = Web3.Utils.formatToEthereumUnits(response,
                                                                           toUnits: .eth,
                                                                           decimals: 8,
                                                                           fallbackToScientific: true)
                    DispatchQueue.main.async {
                        UserDefaults.saveData(string: formattedAmount!)
                    }
                }
            case .Error(let error):
                print("\(error)")
            }
        }
    }

    private func prepareNavbar() {
        navigationItem.title = NSLocalizedString("Settings", comment: "")
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    
    private func updateUI() {
        guard let selectedWallet = walletService.selectedWallet() else { return  }
        nameWalletLabel.text = selectedWallet.name
        nameNetworkLabel.text = networkService.preferredNetwork().networkName
    }
}

extension SettingsViewController:WalletsDelegate {
    func didTapped(with wallet: HDKey) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
            UserDefaults.saveData(string: wallet.name!)
        }
        updateBalance()
    }
}
extension SettingsViewController:NetworkDelegate {
    func didTapped(with network: CustomNetwork) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

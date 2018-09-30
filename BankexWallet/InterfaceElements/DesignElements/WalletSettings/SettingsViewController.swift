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
    
    
    enum SettingsSections:Int,CounableProtocol {
        case Main = 0,AppStore,SocialNetwork
        
        static var count: Int = {
            var max = 0
            while let _ = SettingsSections(rawValue: max) { max += 1 }
            return max
        }()
    }
    
    let managerReferences = ManagerReferences()
    let walletService = SingleKeyServiceImplementation()
    let networkService = NetworksServiceImplementation()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
        configureNavBar()
    }
    
    
     
    
    func configureNavBar() {
        navigationController?.navigationBar.shadowImage = UIImage()
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
        }else if segue.identifier == "walletSegue" {
            let dest = segue.destination as! WalletsViewController
            dest.delegate = self
        }
    }
    
    
}

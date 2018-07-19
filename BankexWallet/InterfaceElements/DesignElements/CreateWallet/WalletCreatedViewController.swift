//
//  WalletCreatedViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit


class WalletCreatedViewController: UIViewController, NameChangingDelegate {
    
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    
    var address: String?
    
    var service: HDWalletService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        walletAddressLabel.text = address
        navigationItem.title = "Creating Wallet"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        self.navigationItem.leftBarButtonItem = nil
    }
    
    @objc func editButtonTapped() {
        performSegue(withIdentifier: "showEdit", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditWalletNameController {
            vc.delegate = self
        }
    }
    
    func nameChanged(to name: String) {
        walletNameLabel.text = name
        guard let address = address else { return }
        service.updateWalletName(walletAddress: address, newName: name) { (error) in
            print(error as Any)
            //TODO: - Alert!
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        WalletCreationTypeRouterImplementation().exitFromTheScreen()
    }
}

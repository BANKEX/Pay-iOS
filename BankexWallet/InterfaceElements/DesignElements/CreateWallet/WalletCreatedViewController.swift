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
        navigationBarSetup()

    }
    
    @objc func editButtonTapped() {
        performSegue(withIdentifier: "showEdit", sender: nil)
    }
    
    func navigationBarSetup() {
        navigationItem.title = NSLocalizedString("Creating Wallet", comment: "")
        let editBtn = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        editBtn.accessibilityLabel = "EditBtn"
        navigationItem.rightBarButtonItem = editBtn
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditWalletNameController {
            vc.delegate = self
        }
        if let vc = segue.destination as? SendingInProcessViewController {
            vc.fromEnterScreen = true
        }
    }
    
    func nameChanged(to name: String) {
        walletNameLabel.text = name
        guard let address = address else { return }
        service.updateWalletName(walletAddress: address, newName: name) { (error) in
            if error != nil { self.showAlert() }
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Could not rename the wallet", comment: ""), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showProcessFromCreation", sender: self)
        }
        //WalletCreationTypeRouterImplementation().exitFromTheScreen()
    }
}

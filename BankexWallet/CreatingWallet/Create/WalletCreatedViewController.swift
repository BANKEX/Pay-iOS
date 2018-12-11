//
//  WalletCreatedViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        statusBarColor(UIDevice.isIpad ? .white : UIColor.greenColor)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func editButtonTapped() {
        if UIDevice.isIpad {
            let editVC = CreateVC(byName: "EditWalletNameController") as! EditWalletNameController
            editVC.addCancelButtonIfNeed()
            editVC.delegate = self
            presentPopUp(editVC, shower: tabBarController)
        }else {
            performSegue(withIdentifier: "showEdit", sender: nil)
        }
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
    
    func presentPasscode() {
        let passcode = CreateVC(byName: "PasscodeIpadVC") as! PasscodeIpadVC
        passcode.delegate = self
        passcode.modalPresentationStyle = .formSheet
        passcode.preferredContentSize = CGSize(width: 320, height: 600)
        present(passcode, animated: true, completion: nil)
    }
    
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if UIDevice.isIpad && !UserDefaults.standard.bool(forKey: "passcodeExists") {
            presentPasscode()
        }else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showProcessFromCreation", sender: self)
            }
        }
    }
}

extension WalletCreatedViewController:PasscodeIpadVCDelegate {
    func didCreate() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showProcessFromCreation", sender: self)
        }
    }
}

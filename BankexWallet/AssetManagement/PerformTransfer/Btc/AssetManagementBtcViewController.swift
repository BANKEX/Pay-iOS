//
//  AssetManagementBtcViewController.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 29/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class AssetManagementBtcViewController: UIViewController {
    
    @IBOutlet private var destinationAddressLabel: UILabel!
    @IBOutlet private var agreementSwitch: UISwitch!
    @IBOutlet private var riskFactorSwitch: UISwitch!
    @IBOutlet private var copyButton: UIButton!
    
    private let destination = "367aqxeq6SqVzaX5qza2HwvfxTJeruLoka"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateView()
    }

    @IBAction private func agreementChecked() {
        updateView()
    }
    
    @IBAction private func riskFactorChecked() {
        updateView()
    }
    
    @IBAction private func openAgreement() {
        let pageURL = URL(string: "https://bankex.com/en/sto/asset-management")!
        
        UIApplication.shared.openURL(pageURL)
    }
    
    @IBAction private func openRiskFactor() {
        let pageURL = URL(string: "https://bankex.com/en/sto/asset-management")!
        
        UIApplication.shared.openURL(pageURL)
    }
        
    @IBAction func copyDestinationAddress() {
        UIPasteboard.general.string = destination
    }
    
    @IBAction func finish() {
        performSegue(withIdentifier: "Home", sender: self)
    }
    
}

private extension AssetManagementBtcViewController {
    
    func updateView() {
        destinationAddressLabel.text = destination
        
        copyButton.isEnabled = agreementSwitch.isOn && riskFactorSwitch.isOn
    }
    
}

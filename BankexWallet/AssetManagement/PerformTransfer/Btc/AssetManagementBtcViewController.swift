//
//  AssetManagementBtcViewController.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 29/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class AssetManagementBtcViewController: UIViewController {
    
    @IBOutlet private var destinationContainerView: UIView!
    @IBOutlet private var destinationAddressLabel: UILabel!
    @IBOutlet private var sectionSegmentedControl: UISegmentedControl!
    @IBOutlet private var sendContainerView: UIView!
    @IBOutlet private var contactsContainerView: UIView!
    @IBOutlet private var infoContainerView: UIView!
    @IBOutlet private var agreementButton: UIButton!
    @IBOutlet private var riskFactorButton: UIButton!
    @IBOutlet private var copyButton: UIButton!
    
    private let destination = "367aqxeq6SqVzaX5qza2HwvfxTJeruLoka"
    private var agreementChecked = false
    private var riskFactorChecked = false
    private var linkToOpen: URL!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateView()
    }
    
    @IBAction private func sectionChanged() {
        updateView()
    }
    
    @IBAction private func toggleAgreementChecked() {
        agreementChecked = agreementChecked == false
        
        updateView()
    }
    
    @IBAction private func toggleRiskFactorChecked() {
        riskFactorChecked = riskFactorChecked == false
        
        updateView()
    }
    
    @IBAction private func openAgreement() {
        linkToOpen = URL(string: "https://bankex.com/en/sto/asset-management")!
        performSegue(withIdentifier: "Browser", sender: self)
    }
    
    @IBAction private func openRiskFactor() {
        linkToOpen = URL(string: "https://bankex.com/en/sto/asset-management")!
        performSegue(withIdentifier: "Browser", sender: self)
    }
        
    @IBAction func copyDestinationAddress() {
        UIPasteboard.general.string = destination
    }
    
    @IBAction func finish() {
        performSegue(withIdentifier: "Home", sender: self)
    }
    
}

extension AssetManagementBtcViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let browser = segue.destination as? AssetManagementBrowserViewController {
            browser.link = linkToOpen
        }
    }
    
}


private extension AssetManagementBtcViewController {
    
    func updateView() {
        agreementButton.isSelected = agreementChecked
        riskFactorButton.isSelected = riskFactorChecked
        
        let allowTransfer = agreementChecked && riskFactorChecked
        
        destinationAddressLabel.text = allowTransfer ? destination : "—"
        copyButton.isEnabled = allowTransfer
        
        destinationAddressLabel.alpha = allowTransfer ? 1.0 : 0.3
        copyButton.alpha = allowTransfer ? 1.0 : 0.3
        
        sendContainerView.isHidden = sectionSegmentedControl.selectedSegmentIndex != 0
        contactsContainerView.isHidden = sectionSegmentedControl.selectedSegmentIndex != 1
        infoContainerView.isHidden = sectionSegmentedControl.selectedSegmentIndex != 2
    }
    
}

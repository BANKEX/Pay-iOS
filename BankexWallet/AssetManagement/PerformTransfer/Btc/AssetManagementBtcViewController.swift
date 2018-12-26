//
//  AssetManagementBtcViewController.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 29/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import Amplitude_iOS

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
    @IBOutlet private var clipboardViewHiddingContraint: NSLayoutConstraint!
    
    private let destination = "367aqxeq6SqVzaX5qza2HwvfxTJeruLoka"
    private var agreementChecked = false
    private var riskFactorChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: BackButtonView.create(self, action: #selector(finish)))
    }
    
    @objc func finish() {
        performSegue(withIdentifier: "Home", sender: self)
    }
    
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
        Amplitude.instance()?.logEvent("Asset Management BTC Agreement Opened")
        
        let url = URL(string: "https://bankex.github.io/pay-asset-management/docs/agreement.pdf")!
        AssetManagementBrowser().present(on: self, url: url)
    }
    
    @IBAction private func openRiskFactor() {
        Amplitude.instance()?.logEvent("Asset Management BTC Risk Factor Opened")
        
        let url = URL(string: "https://bankex.github.io/pay-asset-management/docs/risk-factors.pdf")!
        AssetManagementBrowser().present(on: self, url: url)
    }
        
    @IBAction func copyDestinationAddress() {
        Amplitude.instance()?.logEvent("Asset Management BTC Address Copied")
        
        UIPasteboard.general.string = destination
        UIView.animate(withDuration: 0.6,animations: {
            self.clipboardViewHiddingContraint.isActive = true
            self.view.layoutIfNeeded()
        }) { (_) in
            UIView.animate(withDuration: 0.6,delay:0.5,animations: {
                self.clipboardViewHiddingContraint.isActive = false
                self.view.layoutIfNeeded()
            })
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

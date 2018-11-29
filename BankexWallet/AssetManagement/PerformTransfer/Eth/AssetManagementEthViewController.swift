//
//  AssetManagementPerformEthTransferViewController.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 28/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import BigInt
import web3swift

class AssetManagementEthViewController: UIViewController {
    
    @IBOutlet private var walletNameLabel: UILabel!
    @IBOutlet private var walletAddressLabel: UILabel!
    @IBOutlet private var walletBalanceLabel: UILabel!
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var destinationAddressLabel: UILabel!
    @IBOutlet private var amountTextField: UITextField!
    @IBOutlet private var feeLabel: UILabel!
    @IBOutlet private var totalLabel: UILabel!
    @IBOutlet private var agreementSwitch: UISwitch!
    @IBOutlet private var riskFactorSwitch: UISwitch!
    @IBOutlet private var sendButton: UIButton!
    
    private let keyService = SingleKeyServiceImplementation()
    private let utilsService = UtilTransactionsServiceImplementation()
    private let tokensService = CustomERC20TokensServiceImplementation()
    
    private var walletBalance: BigUInt?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateView()
        updateBalance()
    }
    
    @IBAction private func finish() {
        performSegue(withIdentifier: "Home", sender: self)
    }
    
}

private extension AssetManagementEthViewController {
    
    func updateBalance() {
        guard let selectedAddress = keyService.selectedAddress() else { return }
        let selectedToken = tokensService.selectedERC20Token()
        
        utilsService.getBalance(for: selectedToken.address, address: selectedAddress) { [weak self] (result) in
            switch result {
            case .Success(let response):
                DispatchQueue.main.async {
                    self?.walletBalance = response
                    self?.updateView()
                }
            case .Error: break
            }
        }
    }
    
}

private extension AssetManagementEthViewController {
    
    func updateView() {
        guard let wallet = keyService.selectedWallet() else { return }
        
        walletNameLabel.text = wallet.name
        walletAddressLabel.text = wallet.address.formattedAddrToken()
        
        let walletBalanceText: String?
        if let walletBalance = walletBalance, let formatted = Web3.Utils.formatToEthereumUnits(walletBalance, toUnits: .eth, decimals: 8, fallbackToScientific: true) {
            walletBalanceText = formatted
        } else {
            walletBalanceText = LocalizedStrings.walletBalanceEmptyValue
        }
        
        walletBalanceLabel.text = walletBalanceText
        
        infoLabel.text = LocalizedStrings.info
    }
    
}

private extension AssetManagementEthViewController {
    
    struct LocalizedStrings {
        static let walletBalanceEmptyValue = NSLocalizedString("WalletBalance.EmptyValue", tableName: "AssetManagementEthViewController", comment: "")
        static let info = NSLocalizedString("Info", tableName: "AssetManagementEthViewController", comment: "")
    }
    
}

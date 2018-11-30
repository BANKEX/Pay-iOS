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
    @IBOutlet private var sendButton: ActionButton!
    
    private let keyService = SingleKeyServiceImplementation()
    private let utilsService = UtilTransactionsServiceImplementation()
    private let tokensService = CustomERC20TokensServiceImplementation()
    private let transactionService = TransactionsService()
    
    private let destination = EthereumAddress("0x0123456789012345678901234567890123456789")!
    private var walletBalance: BigUInt?
    private var amount: BigUInt?
    private var fee: BigUInt? = 0
    private var total: BigUInt?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        updateBalance()
        updateFee()
    }
    
    @IBAction private func amountChanged() {
        updateAmount()
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
    
    @IBAction private func endEditing() {
        view.endEditing(true)
    }
    
    @IBAction private func send() {
        performSegue(withIdentifier: "Progress", sender: self)
    }
    
    @IBAction private func finish() {
        performSegue(withIdentifier: "Home", sender: self)
    }
    
}

extension AssetManagementEthViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? AssetManagementEthProgressViewController {
            viewController.amount = amountTextField.text
            viewController.toAddress = destination.address
        }
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
    
    func updateFee() {
        transactionService.requestGasPrice { gasPrice in
            guard let gasPrice = gasPrice else { return }
            let gasLimit = Double(21000)
            self.fee = BigUInt(gasPrice * pow(10, 9) * gasLimit)
            self.updateView()
        }
    }
    
    func updateAmount() {
        let amountText = amountTextField.text ?? ""
        
        amount = Web3.Utils.parseToBigUInt(amountText, units: .eth)
        
        updateTotals()
    }
    
    func updateTotals() {
        if let amount = amount, let fee = fee {
            total = amount + fee
        } else {
            total = nil
        }
        
        updateView()
    }
    
}

private extension AssetManagementEthViewController {
    
    func formatted(value: BigUInt?) -> String {
        guard
            let value = value,
            let formatted = Web3.Utils.formatToEthereumUnits(value, toUnits: .eth, decimals: 8, fallbackToScientific: true)
            else { return "—" }
        
        return formatted + " ETH"
    }
    
    func updateView() {
        guard let wallet = keyService.selectedWallet() else { return }
        
        walletNameLabel.text = wallet.name
        walletAddressLabel.text = wallet.address.formattedAddrToken()
        walletBalanceLabel.text = formatted(value: walletBalance)
        
        infoLabel.text = LocalizedStrings.info
        
        destinationAddressLabel.text = destination.address.formattedAddrToken()
        
        feeLabel.text = formatted(value: fee)
        totalLabel.text = formatted(value: total)
        
        sendButton.isEnabled = agreementSwitch.isOn && riskFactorSwitch.isOn && (amount ?? 0) > 0
        sendButton.backgroundColor = sendButton.isEnabled ? UIColor.mainColor : UIColor.lightBlue
    }
    
}

private extension AssetManagementEthViewController {
    
    struct LocalizedStrings {
        static let info = NSLocalizedString("Info", tableName: "AssetManagementEthViewController", comment: "")
    }
    
}

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
    @IBOutlet private var sourceAddressLabel: UILabel!
    @IBOutlet private var destinationAddressLabel: UILabel!
    @IBOutlet private var sectionSegmentedControl: UISegmentedControl!
    @IBOutlet private var sendContainerView: UIView!
    @IBOutlet private var contactsContainerView: UIView!
    @IBOutlet private var infoContainerView: UIView!
    @IBOutlet private var amountTextField: UITextField!
    @IBOutlet private var feeLabel: UILabel!
    @IBOutlet private var totalLabel: UILabel!
    @IBOutlet private var agreementSwitch: UISwitch!
    @IBOutlet private var riskFactorSwitch: UISwitch!
    @IBOutlet private var sendButton: ActionButton!
    @IBOutlet private var scrollView:UIScrollView!
    
    private let keyService = SingleKeyServiceImplementation()
    private let utilsService = UtilTransactionsServiceImplementation()
    private let tokensService = CustomERC20TokensServiceImplementation()
    private let transactionService = TransactionsService()
    
    private let destination = EthereumAddress("0x2BBE012F440Dd7339c189a6b0cA057874e72D2D5")!
    private var walletBalance: BigUInt?
    private var amount: BigUInt?
    private var fee: BigUInt?
    private var total: BigUInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        updateBalance()
        updateFee()
    }
    
    @IBAction private func sectionChanged() {
        updateView()
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
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        var bottomPadding:CGFloat
        if #available(iOS 11.0, *) {
            bottomPadding = keyboardFrame.size.height - view.safeAreaInsets.bottom
        }else {
            bottomPadding = keyboardFrame.size.height
        }
        scrollView.contentInset.bottom = bottomPadding + 10
        scrollView.scrollIndicatorInsets.bottom = bottomPadding + 10
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
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
        
        sourceAddressLabel.text = walletAddressLabel.text
        destinationAddressLabel.text = destination.address.formattedAddrToken()
        
        feeLabel.text = formatted(value: fee)
        totalLabel.text = formatted(value: total)
        
        let allowTransfer = agreementSwitch.isOn && riskFactorSwitch.isOn && (amount ?? 0) > 0
        
        sendButton.isEnabled = allowTransfer
        sendButton.alpha = allowTransfer ? 1.0 : 0.3
        
        sendContainerView.isHidden = sectionSegmentedControl.selectedSegmentIndex != 0
        contactsContainerView.isHidden = sectionSegmentedControl.selectedSegmentIndex != 1
        infoContainerView.isHidden = sectionSegmentedControl.selectedSegmentIndex != 2
    }
    
}

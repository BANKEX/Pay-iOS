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
import Amplitude_iOS

class AssetManagementEthViewController: UIViewController {
    
    enum ValidationError {
        case invalidAmount, amountExceedsMin, amountExceedsMax, totalExceedsAvailable(required: BigUInt, available: BigUInt)
    }
    
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
    @IBOutlet private var validationErrorLabel: UILabel!
    @IBOutlet private var feeLabel: UILabel!
    @IBOutlet private var totalLabel: UILabel!
    @IBOutlet private var agreementButton: UIButton!
    @IBOutlet private var riskFactorButton: UIButton!
    @IBOutlet private var sendButton: ActionButton!
    @IBOutlet private var scrollView:UIScrollView!
    
    private let keyService = SingleKeyServiceImplementation()
    private let utilsService = UtilTransactionsServiceImplementation()
    private let tokensService = CustomERC20TokensServiceImplementation()
    private let transactionService = TransactionsService()
    
    private let decimalCount = 8
    private let minAmount = Web3Utils.parseToBigUInt("400", units: .eth)!
    private let maxAmount = Web3Utils.parseToBigUInt("4000", units: .eth)!
    private let destination = EthereumAddress("0x2BBE012F440Dd7339c189a6b0cA057874e72D2D5")!
    private var walletBalance: BigUInt?
    private var agreementChecked = false
    private var riskFactorChecked = false
    private var amount: BigUInt?
    private var fee: BigUInt?
    private var total: BigUInt?
    private var validationError: ValidationError?
    private var linkToOpen: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: BackButtonView.create(self, action: #selector(finish)))
    }
    
    @objc func finish() {
        performSegue(withIdentifier: "Home", sender: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        validate()
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
    
    @IBAction private func toggleAgreementChecked() {
        agreementChecked = agreementChecked == false
        
        updateView()
    }
    
    @IBAction private func toggleRiskFactorChecked() {
        riskFactorChecked = riskFactorChecked == false
        
        updateView()
    }
    
    @IBAction private func openAgreement() {
        Amplitude.instance()?.logEvent("Asset Management ETH Agreement Opened")
        
        linkToOpen = URL(string: "https://bankex.com/en/sto/asset-management")!
        performSegue(withIdentifier: "Browser", sender: self)
    }
    
    @IBAction private func openRiskFactor() {
        Amplitude.instance()?.logEvent("Asset Management ETH Risk Factor Opened")
        
        linkToOpen = URL(string: "https://bankex.com/en/sto/asset-management")!
        performSegue(withIdentifier: "Browser", sender: self)
    }
    
    @IBAction private func endEditing() {
        view.endEditing(true)
    }
    
    @IBAction private func send() {
        Amplitude.instance()?.logEvent("Asset Management ETH Send Started")
        
        performSegue(withIdentifier: "Progress", sender: self)
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

extension AssetManagementEthViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text else { return false }
        
        let startIndex = text.index(text.startIndex, offsetBy: range.location)
        let endIndex = text.index(startIndex, offsetBy: range.length)

        text.replaceSubrange(startIndex..<endIndex, with: string)
        text = text.trimmingCharacters(in: .whitespaces)
        
        return Web3.Utils.parseToBigUInt(text, decimals: decimalCount) != nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == amountTextField {
            Amplitude.instance()?.logEvent("Asset Management ETH Amount Entered")
        }
    }
    
}

extension AssetManagementEthViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? AssetManagementEthProgressViewController {
            viewController.amount = amountTextField.text
            viewController.toAddress = destination.address
        } else if let browser = segue.destination as? AssetManagementBrowserViewController {
            browser.link = linkToOpen
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
                    
                    self?.validate()
                    self?.updateView()
                }
            case .Error: break
            }
        }
    }
    
    func updateFee() {
        transactionService.requestGasPrice { [weak self] gasPrice in
            guard let gasPrice = gasPrice else { return }
            
            let gasLimit = Double(21000)
            self?.fee = BigUInt(gasPrice * pow(10, 9) * gasLimit)
            
            self?.validate()
            self?.updateView()
        }
    }
    
    func updateAmount() {
        let amountText = (amountTextField.text ?? "").trimmingCharacters(in: .whitespaces)
        
        if amountText.isEmpty == false {
            amount = Web3.Utils.parseToBigUInt(amountText, units: .eth)
        } else {
            amount = nil
        }
        
        updateTotals()
    }
    
    func updateTotals() {
        if let amount = amount, let fee = fee {
            total = amount + fee
        } else {
            total = nil
        }
        
        validate()
        updateView()
    }
    
    func validate() {
        if let text = amountTextField.text, text.count > 0, amount == nil {
            validationError = .invalidAmount
        } else if let amount = amount, amount < minAmount {
            validationError = .amountExceedsMin
        } else if let amount = amount, amount > maxAmount {
            validationError = .amountExceedsMax
        } else if let total = total, let available = walletBalance, total > available {
            validationError = .totalExceedsAvailable(required: total, available: available)
        } else {
            validationError = nil
        }
    }
    
}

private extension AssetManagementEthViewController {
    
    func formatted(value: BigUInt?) -> String {
        guard
            let value = value,
            let formatted = Web3.Utils.formatToEthereumUnits(value, toUnits: .eth, decimals: decimalCount, fallbackToScientific: true)
            else { return "—" }
        
        return formatted + " ETH"
    }
    
    func message(for error: ValidationError) -> String {
        switch error {
        case .invalidAmount:
            return NSLocalizedString("ValidationError.InvalidAmount", tableName: "AssetManagementEth", comment: "")
        case .amountExceedsMin:
            return NSLocalizedString("ValidationError.AmountExceedsMin", tableName: "AssetManagementEth", comment: "")
        case .amountExceedsMax:
            return NSLocalizedString("ValidationError.AmountExceedsMax", tableName: "AssetManagementEth", comment: "")
        case .totalExceedsAvailable(let required, let available):
            var message = NSLocalizedString("ValidationError.TotalExceedsAvailable.Template", tableName: "AssetManagementEth", comment: "")
            message = message.replacingOccurrences(of: "{total}", with: formatted(value: required))
            message = message.replacingOccurrences(of: "{available}", with: formatted(value: available))
            
            return message
        }
    }
    
    func updateView() {
        guard let wallet = keyService.selectedWallet() else { return }
        
        walletNameLabel.text = wallet.name
        walletAddressLabel.text = wallet.address.formattedAddrToken()
        
        if let value = walletBalance {
            walletBalanceLabel.text = Web3.Utils.formatToEthereumUnits(value, toUnits: .eth, decimals: decimalCount, fallbackToScientific: true)
        } else {
            walletBalanceLabel.text = "—"
        }
        
        sourceAddressLabel.text = walletAddressLabel.text
        destinationAddressLabel.text = destination.address.formattedAddrToken()
        
        feeLabel.text = formatted(value: fee)
        totalLabel.text = formatted(value: total)
        
        agreementButton.isSelected = agreementChecked
        riskFactorButton.isSelected = riskFactorChecked
        
        let allowTransfer = agreementChecked && riskFactorChecked && total != nil && validationError == nil
        
        sendButton.isEnabled = allowTransfer
        sendButton.alpha = allowTransfer ? 1.0 : 0.3
        
        sendContainerView.isHidden = sectionSegmentedControl.selectedSegmentIndex != 0
        contactsContainerView.isHidden = sectionSegmentedControl.selectedSegmentIndex != 1
        infoContainerView.isHidden = sectionSegmentedControl.selectedSegmentIndex != 2
        
        if let validationError = validationError {
            validationErrorLabel.text = message(for: validationError)
            amountTextField.textColor = UIColor.errorColor
        } else {
            validationErrorLabel.text = "\u{20}" // Space char to make label height consistent
            amountTextField.textColor = UIColor.mainTextColor
        }
    }
    
}

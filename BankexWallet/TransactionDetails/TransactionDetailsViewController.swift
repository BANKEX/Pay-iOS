//
//  TransactionDetailsViewController.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 19/12/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit
import BigInt
import web3swift

class TransactionDetailsViewController: UIViewController {
    
    var address: String?
    var transaction: ETHTransactionModel? {
        didSet {
            updateView()
            getTransactionDetails(txHash: transaction?.hash)
            getTransactionStatus(txHash: transaction?.hash)
        }
    }
    
    var transactionDetails: TransactionDetails? {
        didSet {
            updateTransactionDetails()
        }
    }
    
    var transactionStatus: TransactionReceipt.TXStatus? {
        didSet {
            updateTransactionStatus()
        }
    }
    
    @IBOutlet private var amountLabel: UILabel!
    @IBOutlet private var symbolLabel: UILabel!
    @IBOutlet private var txHashLabel: UILabel!
    @IBOutlet private var notificationMessageLabel: UILabel!
    @IBOutlet private var notificationViewDisplayingConstraint: NSLayoutConstraint!
    @IBOutlet private var statusLabel: StatusLabel!
    @IBOutlet private var addressFromTitle: UILabel!
    @IBOutlet private var addressFromLabel: UILabel!
    @IBOutlet private var addressToTitle: UILabel!
    @IBOutlet private var addressToLabel: UILabel!
    @IBOutlet private var dateTitleLabel: UILabel!
    @IBOutlet private var dateValueLabel: UILabel!
    @IBOutlet private var blockNumberTitleLabel: UILabel!
    @IBOutlet private var blockNumberValueLabel: UILabel!
    @IBOutlet private var gasPriceTitleLabel: UILabel!
    @IBOutlet private var gasPriceValueLabel: UILabel!
    @IBOutlet private var gasLimitTitleLabel: UILabel!
    @IBOutlet private var gasLimitValueLabel: UILabel!
    @IBOutlet private var feeTitleLabel: UILabel!
    @IBOutlet private var feeValueLabel: UILabel!
    
    private let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.plusSign = ""
        formatter.minusSign = ""
        formatter.nilSymbol = "—"
        formatter.positivePrefix = "+ "
        formatter.negativePrefix = "\u{2212} "
        
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss z, dd MMMM yyyy"
        formatter.timeZone = TimeZone(abbreviation: "EST")
        
        return formatter
    }()
    
    private let txDetailsService: TransactionDetailsService = TransactionDetailsServiceImplementation()
    
    @IBAction func tapBack(_ sender: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapCheckOnEtherscan(_ sender: UITapGestureRecognizer) {
        guard let hash = transaction?.hash,
            let url = URL(string: "https://etherscan.io/tx/\(hash)"),
            UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url)
    }
    
    @IBAction func tapBlockNumber(_ sender: UITapGestureRecognizer) {
        guard let blockNumber = transactionDetails?.blockNumber,
            let url = URL(string: "https://etherscan.io/block/\(blockNumber)"),
            UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavBar()
        getTransactionDetails(txHash: transaction?.hash)
        getTransactionStatus(txHash: transaction?.hash)
        updateView()
    }

    private func configureNavBar() {
        navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarView?.backgroundColor = UIDevice.isIpad ? .white : .disableColor
        UIApplication.shared.statusBarStyle = UIDevice.isIpad ? .default : .`default`
    }
    
    private func getTransactionDetails(txHash: String?) {
        guard let txHash = txHash else {
            transactionDetails = nil
            return
        }
        txDetailsService.getTransactionDetails(txHash: txHash) { [weak self] (txDetails) in
            guard let controller = self, let txDetails = txDetails else { return }
            controller.transactionDetails = txDetails
        }
    }
    
    private func getTransactionStatus(txHash: String?) {
        guard let txHash = txHash else {
            transactionStatus = nil
            return
        }
        txDetailsService.getStatus(txHash: txHash) { [weak self] (txStatus) in
            guard let controller = self, let txStatus = txStatus else { return }
            controller.transactionStatus = txStatus
        }
    }
    
    @IBAction func shareTransactionHash(_ sender: UIButton) {
        guard let hash = transaction?.hash else { return }
        
        let activity = UIActivityViewController.activity(content: hash)
        activity.completionWithItemsHandler = { [weak self] (type, isSuccess, items, error) in
            if isSuccess && type == UIActivityType.copyToPasteboard {
                let message = NSLocalizedString("Sharing.TransactionHashCopied.Message", tableName: "TransactionDetails", comment: "")
                
                self?.showNotification(withMessage: message)
            }
        }
        
        if UIDevice.isIpad {
            activity.addPopover(in: sender, rect: CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0))
        }
        
        present(activity, animated: true)
    }
    
    @IBAction func shareFromAddress() {
        guard let address = transaction?.from else { return }
        
        copyToPasteboard(address: address)
    }
    
    @IBAction func shareToAddress() {
        guard let address = transaction?.to else { return }
        
        copyToPasteboard(address: address)
    }
    
    private func copyToPasteboard(address: String) {
        UIPasteboard.general.string = address
        
        let message = NSLocalizedString("Sharing.AddressCopied.Message", tableName: "TransactionDetails", comment: "")
        
        showNotification(withMessage: message)
    }
    
}

extension TransactionDetailsViewController {
    
    private func updateView() {
        guard isViewLoaded else { return }
        
        let outgoing = address?.lowercased() == transaction?.from.lowercased()
        
        let amount: Decimal? = {
            guard let amountString = transaction?.amount, var amount = Decimal(string: amountString) else { return nil }
            
            if outgoing {
                amount = amount * -1
            }
            
            return amount
        }()
        
        amountLabel.text = amountFormatter.string(for: amount)
        
        symbolLabel.text = transaction?.token.symbol.uppercased()
        txHashLabel.text = transaction?.hash
        
        guard let transaction = transaction else {
            setAddress(isEnabled: false, to: "-", from: "-")
            setDate(isEnabled: false, text: "-")

            return
        }
        
        setAddress(isEnabled: true,
                   to: getFormattedAddress(transaction.to), from: getFormattedAddress(transaction.from))
        setDate(isEnabled: true, text: dateFormatter.string(from: transaction.date))
    }
    
    private func updateTransactionDetails() {
        guard isViewLoaded else { return }

        guard let txDetails = transactionDetails else {
            
            setBlockNumber(isEnabled: false, text: "-")
            setGasPrice(isEnabled: false, text: "-")
            setGasLimit(isEnabled: false, text: "-")
            setFee(isEnabled: false, text: "-")
            
            return
        }
        
        if let blockNumber = txDetails.blockNumber {
            setBlockNumber(isEnabled: true, text: "\(blockNumber)")
        } else {
            setBlockNumber(isEnabled: false, text: "-")
        }
        
        setGasPrice(isEnabled: true, text: {
            guard let gwei = inGwei(txDetails.gasPrice), let eth = inEth(txDetails.gasPrice) else { return nil }
            
            return "\(eth) (\(gwei))"
        }())
        setGasLimit(isEnabled: true, text: "\(txDetails.gasLimit)")
        setFee(isEnabled: true, text: inEth(txDetails.gasPrice * txDetails.gasLimit))
    }
    
    private func updateTransactionStatus() {
        guard isViewLoaded else { return }

        guard let txStatus = transactionStatus else {
            statusLabel.alpha = 0
            return
        }
        
        switch txStatus {
        case .ok:
            statusLabel.status = .success
            statusLabel.text = NSLocalizedString("Status.Success", tableName: "StatusLabel", comment: "")
            
        case .failed:
            statusLabel.status = .failed
            statusLabel.text = NSLocalizedString("Status.Failed", tableName: "StatusLabel", comment: "")
            
        case .notYetProcessed:
            statusLabel.status = .pending
            statusLabel.text = NSLocalizedString("Status.Pending", tableName: "StatusLabel", comment: "")
        }
        
        if statusLabel.alpha < 1 {
            UIView.animate(withDuration: 0.3) {
                self.statusLabel.alpha = 1
            }
        }
    }
    
}

extension TransactionDetailsViewController {
    
    private func showNotification(withMessage message: String) {
        notificationMessageLabel.text = message
        
        UIView.animate(withDuration: 0.6, animations: {
            self.notificationViewDisplayingConstraint.isActive = true
            self.view.layoutIfNeeded()
        }) { (_) in
            UIView.animate(withDuration: 0.6, delay:0.5, animations: {
                self.notificationViewDisplayingConstraint.isActive = false
                self.view.layoutIfNeeded()
            })
        }
    }
    
}

extension TransactionDetailsViewController {
    
    private func setAddress(isEnabled: Bool, to: String?, from: String?) {
        
        addressToTitle.isEnabled = isEnabled
        addressToLabel.text = to
        
        addressFromTitle.isEnabled = isEnabled
        addressFromLabel.text = from
    }
    
    private func setDate(isEnabled: Bool, text: String?) {
        dateTitleLabel.isEnabled = isEnabled
        dateValueLabel.isEnabled = isEnabled
        dateValueLabel.text = text
    }
    
    private func setBlockNumber(isEnabled: Bool, text: String?) {
        blockNumberTitleLabel.isEnabled = isEnabled
        blockNumberValueLabel.isEnabled = isEnabled
        blockNumberValueLabel.text = text
    }
    
    private func setGasPrice(isEnabled: Bool, text: String?) {
        gasPriceTitleLabel.isEnabled = isEnabled
        gasPriceValueLabel.isEnabled = isEnabled
        gasPriceValueLabel.text = text
    }
    
    private func setGasLimit(isEnabled: Bool, text: String?) {
        gasLimitTitleLabel.isEnabled = isEnabled
        gasLimitValueLabel.isEnabled = isEnabled
        gasLimitValueLabel.text = text
    }
    
    private func setFee(isEnabled: Bool, text: String?) {
        feeTitleLabel.isEnabled = isEnabled
        feeValueLabel.isEnabled = isEnabled
        feeValueLabel.text = text
    }
}

extension TransactionDetailsViewController {
    
    private func getFormattedAddress(_ address: String) -> String {
        let offset = 5
        
        return String(address[address.startIndex..<address.index(address.startIndex, offsetBy: offset)]
            + "..." + address[address.index(address.endIndex, offsetBy: -offset)..<address.endIndex])
    }

}

extension TransactionDetailsViewController {
    
    private func inGwei(_ value: BigUInt) -> String? {
        guard let gwei = Web3.Utils.formatToEthereumUnits(value, toUnits: .Gwei) else { return nil }
        
        return "\(trimInsignificantLastZeros(gwei)) Gwei"
    }
    
    private func inEth(_ value: BigUInt) -> String? {
        guard let eth = Web3.Utils.formatToEthereumUnits(value, toUnits: .eth, decimals: 9) else { return nil }
        
        return "\(trimInsignificantLastZeros(eth)) ETH"
    }
    
    private func trimInsignificantLastZeros(_ string: String) -> String {
        var string = string
        while string.hasSuffix("0") {
            string = String(string.dropLast())
        }
        
        return string
    }
}

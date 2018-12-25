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
        }
    }
    
    var transactionDetails: TransactionDetails?
    var transactionStatus: TransactionReceipt.TXStatus?
    
    @IBOutlet private var amountLabel: UILabel!
    @IBOutlet private var symbolLabel: UILabel!
    @IBOutlet private var txHashLabel: UILabel!
    @IBOutlet private var notificationMessageLabel: UILabel!
    @IBOutlet private var notificationViewDisplayingConstraint: NSLayoutConstraint!
    @IBOutlet private var statusLabel: StatusLabel!
    @IBOutlet private var addressFromTitleLabel: UILabel!
    @IBOutlet private var addressFromValueLabel: UILabel!
    @IBOutlet private var addressToTitleLabel: UILabel!
    @IBOutlet private var addressToValueLabel: UILabel!
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
        loadTransactionDetails(txHash: transaction?.hash)
        loadTransactionStatus(txHash: transaction?.hash)
        updateView()
    }

    private func configureNavBar() {
        navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarView?.backgroundColor = UIDevice.isIpad ? .white : .disableColor
        UIApplication.shared.statusBarStyle = UIDevice.isIpad ? .default : .`default`
    }
    
    private func loadTransactionDetails(txHash: String?) {
        guard let txHash = txHash else { return }
        
        txDetailsService.getTransactionDetails(txHash: txHash, completion: loadTransactionDetailsHandler)
    }
    
    private lazy var loadTransactionDetailsHandler: (TransactionDetails?)->Void = { [weak self] (txDetails) in
        guard let controller = self else { return }
        
        controller.transactionDetails = txDetails
        
        controller.updateBlockNumber()
        controller.updateGasPrice()
        controller.updateGasLimit()
        controller.updateFee()
    }
    
    private func loadTransactionStatus(txHash: String?) {
        guard let txHash = txHash else { return }
        
        txDetailsService.getStatus(txHash: txHash, completion: loadTransactionStatusHandler)
    }
    
    private lazy var loadTransactionStatusHandler: (TransactionReceipt.TXStatus?)->Void = { [weak self] (txStatus) in
        guard let controller = self else { return }
        
        controller.transactionStatus = txStatus
        
        controller.updateStatus()
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
        
        updateAddress()
        updateDate()
    }
    
    private func updateAddress() {
        guard isViewLoaded else { return }
        
        if let transaction = transaction {
            addressToTitleLabel.isEnabled = true
            addressToValueLabel.text = transaction.to
            addressFromTitleLabel.isEnabled = true
            addressFromValueLabel.text = transaction.from
        } else {
            addressToTitleLabel.isEnabled = false
            addressToValueLabel.text = "-"
            addressFromTitleLabel.isEnabled = false
            addressFromValueLabel.text = "-"
        }
    }
    
    private func updateDate() {
        guard isViewLoaded else { return }
        
        if let transaction = transaction {
            dateTitleLabel.isEnabled = true
            dateValueLabel.isEnabled = true
            dateValueLabel.text = dateFormatter.string(from: transaction.date)
        } else {
            dateTitleLabel.isEnabled = false
            dateValueLabel.isEnabled = false
            dateValueLabel.text = "-"
        }
    }
    
    private func updateStatus() {
        guard isViewLoaded else { return }

        if let txStatus = transactionStatus {
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
            
        } else {
            
            if statusLabel.alpha > 0 {
                UIView.animate(withDuration: 0.3) {
                    self.statusLabel.alpha = 0
                }
            }
        }
    }
    
    private func updateBlockNumber() {
        guard isViewLoaded else { return }
        
        if let blockNumber = transactionDetails?.blockNumber {
            blockNumberTitleLabel.isEnabled = true
            blockNumberValueLabel.isEnabled = true
            blockNumberValueLabel.text = "\(blockNumber)"
        } else {
            blockNumberTitleLabel.isEnabled = false
            blockNumberValueLabel.isEnabled = false
            blockNumberValueLabel.text = "-"
        }
    }
    
    private func updateGasPrice() {
        guard isViewLoaded else { return }
        
        if let txDetails = transactionDetails {
            gasPriceTitleLabel.isEnabled = true
            gasPriceValueLabel.isEnabled = true
            gasPriceValueLabel.text = {
                guard let gwei = inGwei(txDetails.gasPrice), let eth = inEth(txDetails.gasPrice) else { return nil }
                
                return "\(eth) (\(gwei))"
            }()
        } else {
            gasPriceTitleLabel.isEnabled = false
            gasPriceValueLabel.isEnabled = false
            gasPriceValueLabel.text = "-"
        }
    }
    
    private func updateGasLimit() {
        guard isViewLoaded else { return }
        
        if let txDetails = transactionDetails {
            gasLimitTitleLabel.isEnabled = true
            gasLimitValueLabel.isEnabled = true
            gasLimitValueLabel.text = "\(txDetails.gasLimit)"
        } else {
            gasLimitTitleLabel.isEnabled = false
            gasLimitValueLabel.isEnabled = false
            gasLimitValueLabel.text = "-"
        }
    }
    
    private func updateFee() {
        guard isViewLoaded else { return }
        
        if let txDetails = transactionDetails {
            feeTitleLabel.isEnabled = true
            feeValueLabel.isEnabled = true
            feeValueLabel.text = inEth(txDetails.gasPrice * txDetails.gasLimit)
        } else {
            feeTitleLabel.isEnabled = false
            feeValueLabel.isEnabled = false
            feeValueLabel.text = "-"
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

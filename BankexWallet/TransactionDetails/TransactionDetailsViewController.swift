//
//  TransactionDetailsViewController.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 19/12/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class TransactionDetailsViewController: UIViewController {
    
    var address: String?
    var transaction: ETHTransactionModel? {
        didSet {
            updateView()
        }
    }
    
    @IBOutlet private var amountLabel: UILabel!
    @IBOutlet private var symbolLabel: UILabel!
    @IBOutlet private var txHashLabel: UILabel!
    @IBOutlet private var notificationMessageLabel: UILabel!
    @IBOutlet private var notificationViewDisplayingConstraint: NSLayoutConstraint!
    @IBOutlet private var statusLabel: StatusLabel!
    @IBOutlet private var addressFromLabel: UILabel!
    @IBOutlet private var addressToLabel: UILabel!
    @IBOutlet private var dateTitleLabel: UILabel!
    @IBOutlet private var dateValueLabel: UILabel!
    @IBOutlet private var gasPriceValueLabel: UILabel!
    @IBOutlet private var gasLimitValueLabel: UILabel!
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
    
    let txDetailsService: TransactionDetailsService = TransactionDetailsServiceImplementation()
    
    @IBAction func tapBack(_ sender: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapCheckOnEtherscan(_ sender: UITapGestureRecognizer) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavBar()
        updateView()
    }

    private func configureNavBar() {
        navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarView?.backgroundColor = UIDevice.isIpad ? .white : .disableColor
        UIApplication.shared.statusBarStyle = UIDevice.isIpad ? .default : .`default`
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
        
        updateStatus(txHash: transaction?.hash)
    }
    
    private func updateStatus(txHash: String?) {
        
        guard let txHash = txHash else {
            statusLabel.alpha = 0
            return
        }
        
        if statusLabel.status == nil {
            statusLabel.alpha = 0
        }
        
        txDetailsService.getStatus(txHash: txHash) { [weak self] (status) in
            guard let controller = self, let status = status else { return }
            
            switch status {
            case .ok:
                controller.statusLabel.status = .success
                controller.statusLabel.text = NSLocalizedString("Status.Success", tableName: "StatusLabel", comment: "")
                
            case .failed:
                controller.statusLabel.status = .failed
                controller.statusLabel.text = NSLocalizedString("Status.Failed", tableName: "StatusLabel", comment: "")
                
            case .notYetProcessed:
                controller.statusLabel.status = .pending
                controller.statusLabel.text = NSLocalizedString("Status.Pending", tableName: "StatusLabel", comment: "")
            }
            
            if controller.statusLabel.alpha < 1 {
                UIView.animate(withDuration: 0.3) {
                    controller.statusLabel.alpha = 1
                }
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

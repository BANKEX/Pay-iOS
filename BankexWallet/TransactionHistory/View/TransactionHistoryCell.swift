//
//  TransactionHistoryCell.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/4/2561 BE.
//  Copyright © 2561 BANKEX Foundation. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class TransactionHistoryCell: UITableViewCell {

    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

    @IBOutlet weak var transactionTime: UILabel!
    @IBOutlet weak var transactionTypeLabel: UILabel!
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "dd MMMM, yyyy hh:MM:ss"
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    
    func configure(withTransaction trans: ETHTransactionModel, isLastCell: Bool = false, forMain: Bool = true) {
        let isSend = SingleKeyServiceImplementation().selectedAddress()?.lowercased() == trans.from
        if trans.isPending {
            statusImageView.image = #imageLiteral(resourceName: "Confirming")
            transactionTypeLabel.text = NSLocalizedString("Confirming", comment: "")
        } else {
            statusImageView.image = isSend ? #imageLiteral(resourceName: "Sent") : #imageLiteral(resourceName: "Received")
            transactionTypeLabel.text = isSend ? NSLocalizedString("Sent", comment: "") : NSLocalizedString("Received", comment: "")
        }
        let toLbl = String(format: NSLocalizedString("To: %@", comment: ""), getFormattedAddress(trans.to))
        let fromLbl = String(format: NSLocalizedString("From: %@", comment: ""), getFormattedAddress(trans.from))
        addressLabel.text = isSend ? toLbl : fromLbl
        if trans.amount.first == "." {
            var amount = trans.amount
            amount.insert("0", at:trans.amount.startIndex)
            amountLabel.text = (isSend ? "- " : "+ ") + amount + " " + trans.token.symbol.uppercased()
            return
        }
        amountLabel.text = (isSend ? "- " : "+ ") + trans.amount + " " + trans.token.symbol.uppercased()
        transactionTime.text = forMain ? dateFormatter.string(from: trans.date) : timeFormatter.string(from: trans.date)
    }
    
    private func getFormattedAddress(_ address: String) -> String {
        let formatted = address[address.startIndex..<address.index(address.startIndex, offsetBy: 5)] + "..." + address[address.index(address.endIndex, offsetBy: -5)..<address.endIndex]
        return String(formatted)
        
    }
}

class TransactionHistorySectionCell: UITableViewCell {
    @IBOutlet weak var showMoreButton: UIView!
}

//
//  TransactionHistoryCell.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/4/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
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
            transactionTypeLabel.text = "Confirming"
        } else {
            statusImageView.image = isSend ? #imageLiteral(resourceName: "Sent") : #imageLiteral(resourceName: "Received")
            transactionTypeLabel.text = isSend ? "Sent" : "Received"
        }
        addressLabel.text = isSend ? "To: \(getFormattedAddress(trans.to))" : "From: \(getFormattedAddress(trans.from))"
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

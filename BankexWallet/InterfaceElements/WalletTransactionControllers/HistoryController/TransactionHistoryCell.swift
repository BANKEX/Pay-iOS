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

    @IBOutlet weak var transactionTypeLabel: UILabel!
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY"
        return formatter
    }()
    
    
    func configure(withTransaction trans: ETHTransactionModel, isLastCell: Bool = false) {
        let isSend = SingleKeyServiceImplementation().selectedAddress() == trans.from
        statusImageView.image = isSend ? #imageLiteral(resourceName: "Sent") : #imageLiteral(resourceName: "Received")
        transactionTypeLabel.text = isSend ? "Sent" : "Received"
        addressLabel.text = isSend ? "To: \(trans.to)" : "From: \(trans.from)"
        amountLabel.text = (isSend ? "- " : "+ ") + trans.amount + " " + trans.token.symbol.uppercased()
    }
}

class TransactionHistorySectionCell: UITableViewCell {
    @IBOutlet weak var showMoreButton: UIView!
}

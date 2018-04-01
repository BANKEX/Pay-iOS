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

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY"
        return formatter
    }()
    
    
    func configure(withTransaction: Any) {
        guard let trans = withTransaction as? ETHTransactionModel else {
            return
        }
        statusImageView.image = #imageLiteral(resourceName: "icons-checked")
        dateLabel.text = dateFormatter.string(from: trans.date as Date)
        addressLabel.text = trans.to
        amountLabel.text = trans.amount
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

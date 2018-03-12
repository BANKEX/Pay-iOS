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
        guard let trans = withTransaction as? SendEthTransaction else {
            return
        }
        statusImageView.image = #imageLiteral(resourceName: "icons-checked")
        dateLabel.text = dateFormatter.string(from: trans.date! as Date)
        addressLabel.text = trans.to
        //TODO: nope, please, don't do it like this
        var amountString = Web3.Utils.formatToEthereumUnits(BigUInt(UInt(trans.amount!)!), toUnits: .eth, decimals: 15)
        while amountString?.hasSuffix("0") ?? false {
            amountString?.removeLast()
        }
        amountLabel.text = (amountString ?? "") + " Eth."
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

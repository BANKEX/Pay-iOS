//
//  TransactionInfoCell.swift
//  BankexWallet
//
//  Created by Vladislav on 19.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class TransactionInfoCell: UITableViewCell {
    
    @IBOutlet weak var imageStatus:UIImageView!
    @IBOutlet weak var statusLabel:UILabel!
    @IBOutlet weak var toAddrLabel:UILabel!
    @IBOutlet weak var amountLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var symbolLabel:UILabel!
    @IBOutlet weak var timeLabel:UILabel!
    
    
    
    let keyService = SingleKeyServiceImplementation()
    static let identifer = String(describing: TransactionInfoCell.self)
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    var fromMain:Bool = true
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "dd MMMM, yyyy"
        return formatter
    }()
    
    var transaction:ETHTransactionModel? {
        didSet {
            setData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    private func setData() {
        guard let transaction = transaction else { return }
        let selectedAddr = HistoryMediator.addr?.lowercased() ?? keyService.selectedAddress()?.lowercased()
        let isSend = selectedAddr == transaction.from
        var amount = transaction.amount
        if transaction.amount.first == "." {
            amount.insert("0", at: transaction.amount.startIndex)
        }
        amountLabel.text = (isSend ? "- " : "+ ") + amount
        dateLabel.isHidden = fromMain ? false : true
        timeLabel.text = timeFormatter.string(from: transaction.date)
        dateLabel.text = dateFormatter.string(from: transaction.date)
        let token = transaction.token
        symbolLabel.text = token.symbol.uppercased()
        if transaction.isPending {
            statusLabel.text = "Pending"
            imageStatus.image = #imageLiteral(resourceName: "pending")
        }else {
            statusLabel.text = isSend ? NSLocalizedString("Sent", comment: "") : NSLocalizedString("Received", comment: "")
            let imageName = isSend ? "send_icon" : "receive_icon"
            imageStatus.image = UIImage(named:imageName)
        }
        let toLbl = String(format: NSLocalizedString("To: %@", comment: ""), transaction.to.formattedAddrToken())
        let fromLbl = String(format: NSLocalizedString("From: %@", comment: ""), transaction.from.formattedAddrToken())
        toAddrLabel.text = isSend ? toLbl : fromLbl
    }

    
}

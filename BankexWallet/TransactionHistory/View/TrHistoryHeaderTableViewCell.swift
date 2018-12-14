//
//  TrHistoryHeaderTableViewCell.swift
//  BankexWallet
//
//  Created by Vladislav on 14/12/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class TrHistoryHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet private var dateLabel: UILabel!
    
    static let identifer = String(describing: TrHistoryHeaderTableViewCell.self)
    public var dateText:String? {
        get {
            return dateLabel.text
        }
        set {
            dateLabel.text = newValue
        }
    }
    
}

//
//  PlaceholderCell.swift
//  BankexWallet
//
//  Created by Vladislav on 12.09.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class PlaceholderCell: UITableViewCell {
    
    static let identifier = String(describing: PlaceholderCell.self)

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
    }

    
    
}

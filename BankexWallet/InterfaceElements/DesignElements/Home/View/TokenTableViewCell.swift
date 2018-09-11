//
//  TokenTableViewCell.swift
//  BankexWallet
//
//  Created by Vladislav on 12.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class TokenTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tokenImage:UIImageView!
    @IBOutlet weak var nameToken:UILabel!
    @IBOutlet weak var symbolLabel:UILabel!
    @IBOutlet weak var balanceLbl:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .white
        layer.cornerRadius = 8.0
    }

    
}

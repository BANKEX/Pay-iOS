//
//  CreateTokenCell.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 26.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class CreateTokenCell: UITableViewCell {
    
    @IBOutlet weak var tokenIconImageView: UIImageView!
    @IBOutlet weak var tokenNameLabel: UILabel!
    @IBOutlet weak var tokenAddressLabel: UILabel!
    @IBOutlet weak var tokenAddedImageView: UIImageView!
    
    func configure(with token: ERC20TokenModel, isAvailable: Bool = false) {
        tokenNameLabel.text = token.name + " (\(token.symbol))"
        tokenIconImageView.image = PredefinedTokens(with: token.symbol).image()
        tokenAddressLabel.text = token.address
        tokenAddedImageView.alpha = isAvailable ? 1.0 : 0.0
        
    }
    
}

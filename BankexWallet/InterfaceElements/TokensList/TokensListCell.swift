//
//  TokensListCell.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/15/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class TokensListCell: UITableViewCell {

    @IBOutlet weak var selectedTokenImageView: UIImageView!
    @IBOutlet weak var tokenSymbolLabel: UILabel!
    @IBOutlet weak var tokenNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with token: ERC20TokenModel) {
        tokenSymbolLabel.text = token.symbol
        tokenNameLabel.text = token.name
        selectedTokenImageView.isHidden = !token.isSelected
    }
    
}

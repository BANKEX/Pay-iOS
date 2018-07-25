//
//  EmptySectionCell.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 25.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class EmptySectionCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    func configure(with messageText: String?) {
        
        messageLabel.text = messageText ?? ""
    }
}

//
//  EmptyTableCell.swift
//  BankexWallet
//
//  Created by Vladislav on 13.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class EmptyTableCell: UITableViewCell {
    
    
    static let identifier = String(describing: EmptyTableCell.self)
    
    @IBOutlet weak var emptyLabel:UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        emptyLabel.text = NSLocalizedString("YouDontHave", comment: "")
        selectionStyle = .none
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

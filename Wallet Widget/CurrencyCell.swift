//
//  CurrencyCell.swift
//  Wallet Widget
//
//  Created by Vladislav on 11/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {
    
    @IBOutlet weak var imageCurrency:UIImageView!
    @IBOutlet weak var balanceCurrency:UILabel!
    @IBOutlet weak var nameCurrency:UILabel!
    
    var shortToken:TokenShort! {
        didSet {
            if shortToken != nil {
                setData(balance: nil, name: nil, true)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(balance:String?,name:String?,_ isToken:Bool = false) {
        if !isToken {
            balanceCurrency.text = balance ?? "..."
            nameCurrency.text = name ?? "..."
            imageCurrency.image = UIImage(named:"wallet_widget")
        }else {
            balanceCurrency.text = shortToken.balance
            nameCurrency.text = shortToken.name
        }
    }

    
}

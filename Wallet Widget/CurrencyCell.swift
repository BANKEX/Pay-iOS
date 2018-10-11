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

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(balance:String?,name:String?) {
        balanceCurrency.text = balance ?? "..."
        nameCurrency.text = name ?? "..."
        imageCurrency.image = UIImage(named:"wallet_widget")
    }

    
}

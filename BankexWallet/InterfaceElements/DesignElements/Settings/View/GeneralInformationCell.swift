//
//  GeneralInformationCell.swift
//  BankexWallet
//
//  Created by Vladislav on 27/10/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class GeneralInformationCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel:UILabel?
    @IBOutlet weak var detailLabel:UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func setData(address:String, name:String) {
        nameLabel?.text = name
        detailLabel?.text = address
    }
}

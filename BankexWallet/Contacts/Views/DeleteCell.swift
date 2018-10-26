//
//  DeleteCell.swift
//  BankexWallet
//
//  Created by Vladislav on 26/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class DeleteCell: UITableViewCell {
    
    static let identifier:String = String(describing: DeleteCell.self)


    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = UIColor.bgMainColor
    }
    
}

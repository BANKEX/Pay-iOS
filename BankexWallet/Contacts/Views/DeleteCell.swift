//
//  DeleteCell.swift
//  BankexWallet
//
//  Created by Vladislav on 26/10/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

protocol DeleteCellDelegate:class {
    func didTapRemoveButton()
}

class DeleteCell: UITableViewCell {
    
    static let identifier:String = String(describing: DeleteCell.self)

    
    weak var delegate:DeleteCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = UIColor.bgMainColor
    }
    
    @IBAction func remove() {
        delegate?.didTapRemoveButton()
    }
    
}

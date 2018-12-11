//
//  ContactTableCell.swift
//  BankexWallet
//
//  Created by Vladislav on 26.09.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class ContactTableCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel:UILabel!
    
    
    var contact:FavoriteModel? {
        didSet {
            setData()
        }
    }
    
    static let identifier:String = String(describing: ContactTableCell.self)

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIDevice.isIpad ? .clear : .white
    }
    
    func setData() {
        nameLabel.text = contact?.name
    }
    
}






//func prepare() -> NSMutableAttributedString {
//        var string:NSMutableAttributedString = NSMutableAttributedString(string: contact.name)
//        string.append(NSMutableAttributedString(string: " "))
//        let attr = [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 17.0)]
//        let secondItem = NSMutableAttributedString(string: contact.name, attributes: attr)
//        string.append(secondItem)
//        return string
//    }

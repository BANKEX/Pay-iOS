//
//  ContactCellTableViewCell.swift
//  BankexWallet
//
//  Created by Vladislav on 26.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    @IBOutlet weak var nameContactLabel:UILabel!
    
    
    static var identifier:String {
        return String(describing: self)
    }
    
    
    var contact:FavoriteModel! {
        didSet {
            print(prepare())
            nameContactLabel.text = prepare()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func prepare() -> String {
        let attrDict = [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 17.0)]
        var string = contact.firstName
        let lName = NSAttributedString(string: contact.lastname, attributes: attrDict)
        string += " "
        string += lName.string
        return string
    }

}

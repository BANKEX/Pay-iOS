//
//  FavoritesCollectionViewCell.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina (Agoda) on 5/10/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class FavoritesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    func configure(with contact: (String, String)) {
        let (name, address) = contact
        // TODO: Just Do it
    }
    
}

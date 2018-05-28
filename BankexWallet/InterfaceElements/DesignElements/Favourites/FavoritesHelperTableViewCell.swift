//
//  FavoritesHelperTableViewCell.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 28.05.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class FavoritesHelperTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var shortNameLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(fav: FavoriteModel) {
        nameLbl.text = fav.name
        addressLbl.text = fav.address
        
        let firstLetter = (fav.name as NSString).substring(to: 1)
        
        shortNameLbl.text = firstLetter.capitalized
        let color = UIColor.randomDark()
        profileImgView.backgroundColor = color.withAlphaComponent(0.35)
        profileImgView.layer.cornerRadius = 10
        shortNameLbl.textColor = color
    }

}

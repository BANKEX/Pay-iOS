//
//  CollectionViewCell.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 18/07/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var wordLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.borderWidth = 2
        layer.cornerRadius = frame.height / 2
        layer.borderColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 2
        layer.cornerRadius = frame.height / 2
        layer.borderColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
    }

    func configureCell(withText text: String) {
        wordLabel.text = text
        wordLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
    }
}

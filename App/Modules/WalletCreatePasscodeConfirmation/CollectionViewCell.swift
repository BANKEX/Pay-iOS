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
        initialConfiguration()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialConfiguration()
    }

    func configureCell(withText text: String, isCellRed: Bool = false) {
        wordLabel.text = text
        wordLabel.textColor = isCellRed ? UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1) : UIColor.createWalletCellColor
        backgroundColor = isCellRed ? #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 0.7) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        layer.borderColor = isCellRed ? #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1) : UIColor.createWalletCellColor.cgColor
        
    }
    
    private func initialConfiguration() {
        wordLabel.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        layer.borderWidth = 2
        layer.cornerRadius = frame.height / 2
        layer.borderColor = UIColor.createWalletCellColor.cgColor
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
}

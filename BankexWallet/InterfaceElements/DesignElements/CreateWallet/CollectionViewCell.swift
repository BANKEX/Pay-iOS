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
        wordLabel.textColor = isCellRed ? #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1) : #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        backgroundColor = isCellRed ? #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 0.7) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        layer.borderColor = isCellRed ? #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1) : #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        
    }
    
    private func initialConfiguration() {
        layer.borderWidth = 2
        layer.cornerRadius = frame.height / 2
        layer.borderColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
}

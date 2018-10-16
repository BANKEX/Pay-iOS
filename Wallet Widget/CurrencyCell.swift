//
//  CurrencyCell.swift
//  Wallet Widget
//
//  Created by Vladislav on 11/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {
    
    @IBOutlet weak var imageCurrency:UIImageView!
    @IBOutlet weak var balanceCurrency:UILabel!
    @IBOutlet weak var nameCurrency:UILabel!
    
    var shortToken:TokenShort! {
        didSet {
            setData(balance: nil, name: nil, true)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(balance:String?,name:String?,_ isToken:Bool = false) {
        if !isToken {
            balanceCurrency.text = balance ?? "..."
            nameCurrency.text = name ?? "..."
            imageCurrency.image = UIImage(named:"wallet_widget")
        }else {
            balanceCurrency.text = shortToken.balance
            nameCurrency.text = shortToken.name
            addTokenImage()
        }
    }
    
    private func addTokenImage() {
        let circleView = UIView(frame: CGRect(x: 22, y: 20, width: 64, height: 64)) //Magic)
        circleView.layer.cornerRadius = circleView.bounds.width/2
        circleView.backgroundColor = .white
        let word = UILabel()
        word.frame = circleView.bounds
        word.textColor = UIColor(red: 13/255, green: 169/255, blue: 255/255, alpha: 1)
        word.text = shortToken.name.firstLetter
        word.textAlignment = .center
        word.font = UIFont.boldSystemFont(ofSize: 52.0)
        circleView.addSubview(word)
        contentView.addSubview(circleView)
    }
    
}








extension String {
    var firstLetter:String {
        return self.prefix(1).uppercased()
    }
}

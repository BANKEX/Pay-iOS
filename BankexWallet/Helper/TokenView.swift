//
//  TokenView.swift
//  BankexWallet
//
//  Created by Vladislav on 17.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class TokenView:UIView {
    
    var label:UILabel!
    
    var letter:String? {
        didSet {
            config()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        label = UILabel()
        label.frame.origin = CGPoint(x: self.bounds.midX - self.bounds.width/3, y: 0)
        label.frame.size = CGSize(width: self.bounds.width, height: self.bounds.height)
        label.textColor = WalletColors.mainColor
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 52.0)
        label.backgroundColor = .clear
        self.addSubview(label)
    }
    
    func config() {
        self.label.text = letter
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

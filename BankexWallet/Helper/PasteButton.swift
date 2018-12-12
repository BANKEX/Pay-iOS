//
//  PasteButton.swift
//  BankexWallet
//
//  Created by Vladislav on 17.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class PasteButton:UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        setData()
    }
    
    func setData() {
        self.layer.borderColor = UIColor.mainColor.cgColor
        self.layer.borderWidth = 1.5
        self.layer.cornerRadius = 8.0
        self.setTitle(NSLocalizedString("Paste", comment: ""), for: .normal)
        self.setTitleColor(UIColor.mainColor, for: .normal)
    }
    
    
}

//
//  QRButton.swift
//  BankexWallet
//
//  Created by Vladislav on 17.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class QRButton:UIButton {
    override func awakeFromNib() {
        self.layer.borderColor = UIColor.mainColor.cgColor
        self.layer.borderWidth = 1.5
        self.layer.cornerRadius = 8.0
    }
}

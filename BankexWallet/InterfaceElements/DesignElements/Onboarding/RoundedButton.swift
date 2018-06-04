//
//  RoundedButton.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 01/06/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = self.layer.bounds.size.height / 2
    }
}

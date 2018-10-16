//
//  SwitchButton.swift
//  BankexWallet
//
//  Created by Vladislav on 17/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import UIKit

class SwitchButton:UIButton {
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderWidth = 1.5
        layer.borderColor = WalletColors.mainColor.cgColor
        layer.cornerRadius = bounds.width/2
        backgroundColor = .white
        let arrowImage = UIImageView()
        arrowImage.frame.origin = CGPoint(x: 6, y: 8)
        arrowImage.frame.size = CGSize(width: 8, height: 4)
        arrowImage.image = UIImage(named:"arr")!
        addSubview(arrowImage)
    }

    
    
}

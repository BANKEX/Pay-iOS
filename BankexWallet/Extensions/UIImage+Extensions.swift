//
//  UIImage+Extensions.swift
//  BankexWallet
//
//  Created by Vladislav on 24/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func changeColor(_ color:UIColor) {
        let templateImage =  self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

//
//  SeparatorView.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 05/12/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class SeparatorView: UIView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 1.0 / (window?.screen.scale ?? 1.0))
    }
    
}

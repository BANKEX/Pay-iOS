//
//  BaseSplitViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 22/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class BaseSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredDisplayMode = .allVisible
        view.backgroundColor = UIColor(red: 223/255, green: 226/255, blue: 230/255, alpha: 1)
        presentsWithGesture = false
        preferredPrimaryColumnWidthFraction = 0.4
    }
}

extension UISplitViewController {
    func hide() {
        UIView.animate(withDuration: 0.1) {
            self.preferredPrimaryColumnWidthFraction = 0
        }
    }
    func show() {
        UIView.animate(withDuration: 0.1) {
            self.preferredPrimaryColumnWidthFraction = 0.4
        }
    }
}

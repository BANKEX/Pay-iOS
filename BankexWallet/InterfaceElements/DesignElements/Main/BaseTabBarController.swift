//
//  BaseTabBarController.swift
//  BankexWallet
//
//  Created by Vladislav on 13.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import Hero

class BaseTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        tabBar.tintColor = WalletColors.mainColor
        tabBar.barTintColor = .white
        tabBar.items?.last?.image = UIImage(named:"Wallet")
        tabBar.items?.last?.selectedImage = UIImage(named:"Wallet_Selected")
    }

}

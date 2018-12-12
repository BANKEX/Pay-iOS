//
//  BaseTabBarController.swift
//  BankexWallet
//
//  Created by Vladislav on 13.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        tabBar.tintColor = UIColor.mainColor
        tabBar.barTintColor = .white
        tabBar.items?.first?.image = UIImage(named:"Wallet")
        tabBar.items?.first?.selectedImage = UIImage(named:"Wallet_Selected")
        tabBar.items?[2].image = UIImage(named:"contacts_icon")
        tabBar.items?[2].selectedImage = UIImage(named:"contacts_sel_icon")
        tabBar.items?[1].image = #imageLiteral(resourceName: "history_unsel")
        tabBar.items?[1].selectedImage = #imageLiteral(resourceName: "history")
        tabBar.items?.last?.image = #imageLiteral(resourceName: "Setting")
        tabBar.items?.last?.selectedImage = #imageLiteral(resourceName: "settings_selected")
    }
}


//
//  WalletCreationTypeRouter.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/4/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol WalletCreationRouter {
    func exitFromTheScreen()
}

class WalletCreationTypeRouterImplementation: WalletCreationRouter {
    func exitFromTheScreen() {
        guard let navigationC = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else {
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainTabController")

        navigationC.viewControllers = [controller]
    }
}

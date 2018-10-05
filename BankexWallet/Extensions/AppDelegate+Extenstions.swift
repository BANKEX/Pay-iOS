//
//  AppDelegate+Extenstions.swift
//  BankexWallet
//
//  Created by Vladislav on 05/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import UIKit

extension AppDelegate {
    func showFirstTabController() {
        let tabvc = window?.rootViewController as? BaseTabBarController
        tabvc?.selectedIndex = 0
    }
    
    var isLaunched:Bool {
        guard let _ = window?.rootViewController as? BaseTabBarController else { return false }
        return true
    }
    func storyboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }

}

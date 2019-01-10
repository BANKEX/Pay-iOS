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
        let nav = tabvc?.viewControllers![0] as! BaseNavigationController
        nav.popToRootViewController(animated: false)
        tabvc?.selectedIndex = 0
    }
    
    var isLaunched:Bool {
        if UIDevice.isIpad {
            if window?.rootViewController is UISplitViewController {
                return true
            }else {
                return false
            }
        }
        guard let _ = window?.rootViewController as? BaseTabBarController else { return false }
        return true
    }
    func storyboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    func prepareAppearance() {
        UINavigationBar.appearance().tintColor = UIColor.mainColor
        UITextField.appearance().tintColor = UIColor.mainColor
        UITextView.appearance().tintColor = UIColor.mainColor
        UIWindow.appearance().tintColor = UIColor.mainColor
        UINavigationBar.appearance().barTintColor = UIColor.white
    }
    
    func showInitialVC() {
        let initialNav = storyboard().instantiateInitialViewController() as? UINavigationController
        self.window?.rootViewController = initialNav
        window?.makeKeyAndVisible()
    }
    
    
    func showOnboarding() {
        let onboarding = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController()
        window?.rootViewController = onboarding
        window?.makeKeyAndVisible()
    }
    
    func showTabBar() {
        let tabBar = UIStoryboard(name: "MenuPhone", bundle: nil).instantiateInitialViewController() as! BaseTabBarController
        window?.rootViewController = tabBar
        window?.makeKeyAndVisible()
    }
    
    func rootVC() -> UIViewController? {
        return window?.rootViewController
    }

}

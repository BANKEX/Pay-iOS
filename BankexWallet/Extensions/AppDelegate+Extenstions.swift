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
    func showPasscode() {
        //guard !PasscodeEnterController.isLocked else { return }
        if let vc = storyboard().instantiateViewController(withIdentifier: "passcodeEnterController") as? PasscodeEnterController {
            currentPasscodeViewController = vc
            win2 = UIWindow(frame: UIScreen.main.bounds)
            win2?.backgroundColor = .white
            win2?.rootViewController = vc
            win2?.windowLevel = UIWindowLevelAlert
            win2?.makeKeyAndVisible()
        }
    }
    
    func showOnboarding() {
        let onboarding = storyboard().instantiateViewController(withIdentifier: "OnboardingPage")
        window?.rootViewController = onboarding
        window?.makeKeyAndVisible()
    }
    
    func showTabBar() {
        let tabBar = storyboard().instantiateViewController(withIdentifier: "MainTabController") as? BaseTabBarController
        window?.rootViewController = tabBar
        window?.makeKeyAndVisible()
    }
    
    func rootVC() -> UIViewController? {
        return window?.rootViewController
    }

}

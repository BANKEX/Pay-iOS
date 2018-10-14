//
//  UIApplication+Extenstions.swift
//  BankexWallet
//
//  Created by Vladislav on 07/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    var statusBarView: UIView? {
        if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
    
    class func attachBlur() {
        UIApplication.topViewController()?.view.addBlur()
        UIApplication.topViewController()?.tabBarController?.tabBar.addBlur()
        UIApplication.topViewController()?.navigationController?.navigationBar.addBlur()
    }
    
    class func unattachBlur() {
        UIApplication.topViewController()?.view.removeBlur()
        UIApplication.topViewController()?.tabBarController?.tabBar.removeBlur()
        UIApplication.topViewController()?.navigationController?.navigationBar.removeBlur()
    }
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

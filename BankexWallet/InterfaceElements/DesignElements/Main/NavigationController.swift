//
//  NavigationController.swift
//  BankexWallet
//
//  Created by Vladislav on 14/01/2019.
//  Copyright © 2019 BANKEX Foundation. All rights reserved.
//

import UIKit

protocol NavigationBarAppearanceProvider {
    var navigationBarAppearance : NavigationBarAppearance? { get }
}


class NavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        updateAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateAppearance()
    }
    
    override var viewControllers: [UIViewController] {
        didSet {
            updateAppearance()
        }
    }
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        return super.awakeAfter(using: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateAppearance()
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        updateAppearance()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        updateAppearance()
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let result = super.popViewController(animated: animated)
        updateAppearance()
        return result
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let result = super.popToViewController(viewController, animated: animated)
        updateAppearance()
        return result
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let result = super.popToRootViewController(animated: animated)
        updateAppearance()
        return result
    }
    
    func updateAppearance() {
        guard let navigationBarAppearance = (self.visibleViewController)?.navigationBarAppearance else { return }
        self.navigationBar.barTintColor = navigationBarAppearance.barTintColor
        self.navigationBar.tintColor = navigationBarAppearance.tintColor
        self.navigationBar.shadowImage = navigationBarAppearance.shadowImage
        self.navigationBar.titleTextAttributes = navigationBarAppearance.titleTextAttributes
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return (self.visibleViewController)?.navigationBarAppearance?.statusBarStyle ?? super.preferredStatusBarStyle
    }
    
}

class NavigationBarAppearance {
    
    var barTintColor: UIColor?
    var tintColor: UIColor?
    var titleTextAttributes: [NSAttributedString.Key : Any]?
    var statusBarStyle: UIStatusBarStyle?
    var shadowImage: UIImage?
    
    init(barTintColor: UIColor?, tintColor: UIColor?,titleTextAttributes:[NSAttributedStringKey : Any]?,statusBarStyle: UIStatusBarStyle?, shadowImage: UIImage?) {
        self.barTintColor = barTintColor
        self.tintColor = tintColor
        self.titleTextAttributes = titleTextAttributes
        self.statusBarStyle = statusBarStyle
        self.shadowImage = shadowImage
    }
    
    
    static let whiteStyle: NavigationBarAppearance = NavigationBarAppearance(barTintColor: .white, tintColor: .mainColor, titleTextAttributes: [NSAttributedStringKey.foregroundColor : UIColor.black], statusBarStyle: .default, shadowImage: UIImage())
    
    static let blueStyle: NavigationBarAppearance = NavigationBarAppearance(barTintColor: .mainColor, tintColor: .white, titleTextAttributes: [NSAttributedStringKey.foregroundColor : UIColor.white], statusBarStyle: .lightContent, shadowImage: UIImage())
}

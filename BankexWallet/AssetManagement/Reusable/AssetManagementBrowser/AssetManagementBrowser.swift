//
//  AssetManagementBrowser.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 26/12/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import SafariServices

final class AssetManagementBrowser {
    
    func present(on presenterViewController: UIViewController, url: URL) {
        
        let browser = SFSafariViewController(url: url)
        UIApplication.shared.statusBarView?.backgroundColor = browser.preferredControlTintColor
        UIApplication.shared.statusBarStyle = .default
        
        presenterViewController.present(browser, animated: true, completion: nil)

    }
}

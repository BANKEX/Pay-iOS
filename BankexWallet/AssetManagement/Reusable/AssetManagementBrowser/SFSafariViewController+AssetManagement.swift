//
//  AssetManagementBrowser.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 26/12/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import SafariServices

extension SFSafariViewController {
    
    convenience init(assetManagementUrl: URL) {
        self.init(url: assetManagementUrl)
        
        UIApplication.shared.statusBarView?.backgroundColor = preferredControlTintColor
        UIApplication.shared.statusBarStyle = .default
    }
}

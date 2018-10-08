//
//  UIViewController+Extensions.swift
//  BankexWallet
//
//  Created by Vladislav on 19.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

extension UIViewController {
    public func showCreationAlert() {
        let alertViewController = UIAlertController(title: "Error", message: "Couldn't add key", preferredStyle: .alert)
        alertViewController.addCancel()
        self.present(alertViewController, animated: true)
    }
    
    
    public func customBackButton(title:String? = "  Back") -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named:"BackArrow"), for: .normal)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        btn.setTitleColor(WalletColors.mainColor, for: .normal)
        return btn
    }
    
    public func hideAddRightButton() {
        navigationItem.setRightBarButton(nil, animated: false)
    }
    
    public func navBarColor(_ color:UIColor) {
        navigationController?.navigationBar.barTintColor = color
    }
    
    public func statusBarColor(_ color:UIColor) {
        UIApplication.shared.statusBarView?.backgroundColor = color
    }
    
    public func navBarTintColor(_ color:UIColor) {
        navigationController?.navigationBar.tintColor = color
    }
}

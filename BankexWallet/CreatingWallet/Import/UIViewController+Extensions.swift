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
        alertViewController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        self.present(alertViewController, animated: true)
    }
    
    public func hideAddRightButton() {
        navigationItem.setRightBarButton(nil, animated: false)
    }
}

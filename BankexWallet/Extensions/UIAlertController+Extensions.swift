//
//  UIAlertController+Extensions.swift
//  BankexWallet
//
//  Created by Vladislav on 02/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

extension UIAlertController {
    //Check later
    public class func common(title:String?,message:String?) -> UIAlertController {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertViewController.addOK()
        return alertViewController
    }
    
    public class func destructive(title:String? = nil,description:String? = nil, button:String?,action:@escaping ()->()) -> UIAlertController {
        let alertViewController = UIAlertController(title: title, message: description, preferredStyle: .actionSheet)
        alertViewController.addDestructive(title: button, action: action)
        alertViewController.addCancel()
        return alertViewController
    }
    
    public class func destructiveIpad(title:String? = nil,description:String? = nil, button:String?,action:@escaping ()->()) -> UIAlertController {
        let alertViewController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertViewController.addDestructive(title: button, action: action)
        alertViewController.addCancel()
        return alertViewController
    }
    
    public func add(title:String?, action:(()->())?) {
        var handler:((UIAlertAction)->Void)?
        if let action = action {
            handler = { _ in
                action()
            }
        }
        let usualButton = UIAlertAction(title: title, style: .default, handler: handler)
        addAction(usualButton)
    }
    
    public func addOK(action:(()->())? = nil) {
        var handler:((UIAlertAction)->())?
        if let action = action {
            handler = { _ in
                action()
            }
        }
        let cancel = UIAlertAction(title: "OK", style: .default, handler: handler)
        addAction(cancel)
    }
    
    public func addCancel() {
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        addAction(cancel)
    }
    public func addDestructive(title:String?,action:(()->())? = nil) {
        var handler:((UIAlertAction) -> Void)?
        if let action = action {
            handler = { _ in
                action()
            }
        }
        let destructiveButton = UIAlertAction(title: title, style: .destructive, handler: handler)
        addAction(destructiveButton)
    }

    class func accessCameraAlert() -> UIAlertController {
        let alertVC = UIAlertController(title: "Please Allow Access", message: "BANKEX Pay needs access to your camera so that you can capture QR Code.\n Please go to your device's settings > Privacy > Camera and set BANKEX Pay to ON", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: nil))
        alertVC.add(title: "Settings") {
            if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        return alertVC
    }


    
}

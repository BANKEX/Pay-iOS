//
//  UIActivityViewController+Extensions.swift
//  BankexWallet
//
//  Created by Vladislav on 03/10/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit


extension UIActivityViewController {
    public class func activity(content:String) -> UIActivityViewController {
            let str = content
            let activityViewController = UIActivityViewController(activityItems: [str], applicationActivities: nil)
            return activityViewController
    }
}

//
//  ReplaceSegue.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 30/11/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class ReplaceSegue: UIStoryboardSegue {
    
    override func perform() {
        if let navigationController = source.navigationController {
            var viewControllers = navigationController.viewControllers
            
            if let index = viewControllers.lastIndex(of: source) {
                viewControllers[index] = destination
            }
            
            navigationController.setViewControllers(viewControllers, animated: true)
            
        } else {
            super.perform()
        }
    }
    
}

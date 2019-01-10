//
//  InitialLogicRouter.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/5/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import LocalAuthentication

class InitialLogicRouter {
    
    let keysService = SingleKeyServiceImplementation()
    
    var rootController: UINavigationController?
    
    func navigateToMainControllerIfNeeded(rootControler: UINavigationController) {
        self.rootController = rootControler
        if !UserDefaults.standard.bool(forKey: "passcodeExists") || keysService.selectedWallet() == nil {
            return
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showPasscode(context: .initial)
        }
    }
    
}

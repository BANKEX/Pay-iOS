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
    
    
    
    func useFaceIdToAuth(rootControler: UINavigationController) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] (success, authenticationError) in
                
                DispatchQueue.main.async {
                    if success {
                        rootControler.performSegue(withIdentifier: "showProcess", sender: self)
                        
                        DefaultTokensServiceImplementation().downloadAllAvailableTokensIfNeeded {
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let controller = storyboard.instantiateViewController(withIdentifier: "MainTabController")
                            
                            rootControler.viewControllers = [controller]
                        }
                    } else {
                        // error
                    }
                }
            }
        } else {
            // no biometry
        }
    }
}

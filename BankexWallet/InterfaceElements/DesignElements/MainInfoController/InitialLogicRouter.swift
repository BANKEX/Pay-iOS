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
        if UserDefaults.standard.string(forKey: "Passcode") == nil || keysService.selectedWallet() == nil {
            keysService.delete() { (error) in
                if let _ = error {
                    print(error?.localizedDescription)
                }
                return
            }
        } else {
            rootControler.performSegue(withIdentifier: "showEnterPin", sender: self)
            
//            rootControler.performSegue(withIdentifier: "showProcess", sender: self)
//
//            DefaultTokensServiceImplementation().downloadAllAvailableTokensIfNeeded {
//
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let controller = storyboard.instantiateViewController(withIdentifier: "MainTabController")
//
//                rootControler.viewControllers = [controller]
//            }
        }
        
//        useFaceIdToAuth(rootControler: rootControler)
        
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

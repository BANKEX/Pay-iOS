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
    
    func navigateToMainControllerIfNeeded(rootControler: UINavigationController) {
        guard let _ = keysService.selectedWallet() else {
            return
        }
//        useFaceIdToAuth(rootControler: rootControler)
        rootControler.performSegue(withIdentifier: "showProcess", sender: self)

        DefaultTokensServiceImplementation().downloadAllAvailableTokensIfNeeded {

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MainTabController")

            rootControler.viewControllers = [controller]
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

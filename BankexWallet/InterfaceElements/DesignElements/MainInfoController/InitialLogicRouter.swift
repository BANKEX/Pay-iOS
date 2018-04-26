//
//  InitialLogicRouter.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/5/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class InitialLogicRouter {
    
    let keysService = SingleKeyServiceImplementation()
    
    func navigateToMainControllerIfNeeded(rootControler: UINavigationController) {
        guard let _ = keysService.selectedWallet() else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainTabController")
        
        rootControler.viewControllers = [controller]
        
    }
}

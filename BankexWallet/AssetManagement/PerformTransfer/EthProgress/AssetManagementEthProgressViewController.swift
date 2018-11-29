//
//  AssetManagementEthProgressViewController.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 29/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class AssetManagementEthProgressViewController: UIViewController {
    
    private func showSuccess() {
        performSegue(withIdentifier: "Success", sender: self)
    }
    
    private func showFailure() {
        performSegue(withIdentifier: "Failure", sender: self)
    }
    
}

extension AssetManagementEthProgressViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? AssetManagementEthSuccessViewController {
            
        }
        if let viewController = segue.destination as? AssetManagementEthFailureViewController {
            
        }
    }
    
}

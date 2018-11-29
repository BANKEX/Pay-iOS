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
    
}

extension AssetManagementEthProgressViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? AssetManagementEthSuccessViewController {
            
        }
    }
    
}

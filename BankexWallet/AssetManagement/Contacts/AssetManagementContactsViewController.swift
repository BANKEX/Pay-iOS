//
//  AssetManagementContactsViewController.swift
//  BankexWallet
//
//  Created by Andrew Kozlov on 28/11/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import MessageUI

class AssetManagementContactsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackButton()
    }
    
    func addBackButton() {
        let backButtonView = BackButtonView.create { [weak self] (_) in
            self?.performSegue(withIdentifier: "Home", sender: self)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
    }
    
}

extension AssetManagementContactsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

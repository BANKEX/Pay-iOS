//
//  BaseViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 16.09.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        UIApplication.shared.statusBarView?.backgroundColor = .white
        view.backgroundColor = UIColor.bgMainColor
        navigationController?.navigationBar.isTranslucent = false
    }

    
    

    

}

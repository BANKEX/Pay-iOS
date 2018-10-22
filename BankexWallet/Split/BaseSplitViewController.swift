//
//  BaseSplitViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 22/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class BaseSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredDisplayMode = .allVisible
        view.backgroundColor = UIColor(red: 223/255, green: 226/255, blue: 230/255, alpha: 1)
    }

}

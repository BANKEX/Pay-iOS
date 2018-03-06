//
//  TokenTransferContainerController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina (Agoda) on 3/6/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class TokenTransferContainerController: UIViewController, UIScrollViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: 
    @IBAction func endEditingTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    // MARK: ScrollView
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

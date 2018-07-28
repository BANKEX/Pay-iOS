//
//  ProfileContactViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 28.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ProfileContactViewController: UITableViewController {
    
    var selectedContact:FavoriteModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Selected contact - \(selectedContact.firstName)")
    }

}

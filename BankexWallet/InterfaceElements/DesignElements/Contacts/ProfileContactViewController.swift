//
//  ProfileContactViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 28.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ProfileContactViewController: UITableViewController {
    
    @IBOutlet weak var addressTextField:UITextField?
    @IBOutlet weak var noteTextView:UITextView?
    
    
    
    
    var selectedContact:FavoriteModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    @IBAction func sendFunds() {
        
    }
    
    @IBAction func shareContact() {
        
    }
    
    @IBAction func removeContact() {
        
    }
    

}

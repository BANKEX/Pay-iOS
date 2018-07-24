//
//  SecurityViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 24.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol SecurityViewControllerProtocol:class {
    func switchTouchIDTapped(_ securityViewController:SecurityViewController)
    func switchTouchIDSendFunds(_ securityViewController:SecurityViewController)
    func switchTouchIDMultitask(_ securityViewController:SecurityViewController)
}

class SecurityViewController: UITableViewController {
    
    weak var delegate:SecurityViewControllerProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Security"
    }
    
    
    
    @IBAction func switchTouchID(_ sender:UISwitch) {
        delegate?.switchTouchIDTapped(self)
    }
    
    @IBAction func switchSendFunds(_ sender:UISwitch) {
        delegate?.switchTouchIDSendFunds(self)
    }
    
    @IBAction func switchMultitask(_ sender:UISwitch) {
        delegate?.switchTouchIDMultitask(self)
    }
    
    
    
    
    
    
    //DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "USE TOUCH ID WHEN" : "LOCK APP"
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 67.0 : 54.0
    }
    

}

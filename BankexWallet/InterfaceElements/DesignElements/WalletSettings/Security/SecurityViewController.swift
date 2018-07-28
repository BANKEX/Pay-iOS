//
//  SecurityViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 24.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import LocalAuthentication

protocol SecurityViewControllerProtocol:class {
    func switchTouchIDTapped(_ securityViewController:SecurityViewController,with state:Bool)
    func switchTouchIDSendFunds(_ securityViewController:SecurityViewController,with state:Bool)
    func switchTouchIDMultitask(_ securityViewController:SecurityViewController,with state:Bool)
}

class SecurityViewController: UITableViewController {
    
    @IBOutlet weak var openSwitch:UISwitch!
    @IBOutlet weak var sendSwitch:UISwitch!
    @IBOutlet weak var multitaskSwitch:UISwitch!
    
    weak var delegate:SecurityViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Security"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        [openSwitch,sendSwitch,multitaskSwitch].forEach { item in
            item?.isEnabled = TouchManager.canAuth() ? true : false
        }
    }
    
    
    
    @IBAction func switchTouchID(_ sender:UISwitch) {
        if sender.isOn {
            TouchManager.authenticateBioMetrics(reason: "", success: {
                print("Success")
            }) { (error) in
            }
        }
        delegate?.switchTouchIDTapped(self, with: sender.isOn)
    }
    
    @IBAction func switchSendFunds(_ sender:UISwitch) {
        if sender.isOn {
            TouchManager.authenticateBioMetrics(reason: "", success: {
                print("Success")
            }) { (error) in
            }
        }
        delegate?.switchTouchIDSendFunds(self, with: sender.isOn)
    }
    
    @IBAction func switchMultitask(_ sender:UISwitch) {
        if sender.isOn {
            TouchManager.authenticateBioMetrics(reason: "", success: {
                print("Success")
            }) { (error) in
            }
        }
        delegate?.switchTouchIDMultitask(self, with: sender.isOn)
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

//
//  SecurityViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 24.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import LocalAuthentication



class SecurityViewController: UITableViewController {
    
    @IBOutlet weak var openSwitch:UISwitch!
    @IBOutlet weak var sendSwitch:UISwitch!
    @IBOutlet weak var multitaskSwitch:UISwitch!
    
    enum SecuritySections:Int {
        case First = 0,Second
    }
    
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
                sender.setOn(false, animated: false)
            }
        }
        NotificationCenter.default.post(name:SwitchChangeNotifications.didChangeOpenSwitch.notificationName(), object: self, userInfo:["state":sender.isOn])
    }
    
    @IBAction func switchSendFunds(_ sender:UISwitch) {
        if sender.isOn {
            TouchManager.authenticateBioMetrics(reason: "", success: {
                print("Success")
            }) { (error) in
                sender.setOn(false, animated: false)
            }
        }
        NotificationCenter.default.post(name:SwitchChangeNotifications.didChangeSendSwitch.notificationName(), object: self, userInfo:["state":sender.isOn])
    }
    
    @IBAction func switchMultitask(_ sender:UISwitch) {
        if sender.isOn {
            TouchManager.authenticateBioMetrics(reason: "", success: {
                print("Success")
            }) { (error) in
                sender.setOn(false, animated: false)
            }
        }
        NotificationCenter.default.post(name:SwitchChangeNotifications.didChangeMultiSwitch.notificationName(), object: self, userInfo:["state":sender.isOn])
    }
    
    
    
    
    
    
    //DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == SecuritySections.First.rawValue ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == SecuritySections.First.rawValue ? "USE TOUCH ID WHEN" : "LOCK APP"
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == SecuritySections.First.rawValue ? 67.0 : 54.0
    }
    
    
}

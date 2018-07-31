//
//  SecurityViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 24.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import LocalAuthentication

public enum Keys:String {
    case openSwitch = "open"
    case sendSwitch = "send"
    case multiSwitch = "multi"
}

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
        updateUI()
        [openSwitch,sendSwitch,multitaskSwitch].forEach { item in
            item?.isEnabled = TouchManager.canAuth() ? true : false
        }
    }
    
    
    
    func updateUI() {
        openSwitch.isOn = UserDefaults.standard.value(forKey:Keys.openSwitch.rawValue) as? Bool ?? true
        sendSwitch.isOn = UserDefaults.standard.value(forKey:Keys.sendSwitch.rawValue) as? Bool ?? true
        multitaskSwitch.isOn = UserDefaults.standard.value(forKey:Keys.multiSwitch.rawValue) as? Bool ?? true
    }
    
    
    @IBAction func switchTouchID(_ sender:UISwitch) {
        if sender.isOn {
            TouchManager.authenticateBioMetrics(reason: "", success: {
                print("Success")
            }) { (error) in
                sender.setOn(false, animated: false)
                UserDefaults.standard.set(false, forKey: Keys.openSwitch.rawValue)
            }
        }
        UserDefaults.standard.set(sender.isOn, forKey: Keys.openSwitch.rawValue)
    }
    
    @IBAction func switchSendFunds(_ sender:UISwitch) {
        if sender.isOn {
            TouchManager.authenticateBioMetrics(reason: "", success: {
                print("Success")
            }) { (error) in
                sender.setOn(false, animated: false)
                UserDefaults.standard.set(false, forKey: Keys.sendSwitch.rawValue)
            }
        }
        UserDefaults.standard.set(sender.isOn, forKey: Keys.sendSwitch.rawValue)
    }
    
    @IBAction func switchMultitask(_ sender:UISwitch) {
        if sender.isOn {
            TouchManager.authenticateBioMetrics(reason: "", success: {
                print("Success")
            }) { (error) in
                sender.setOn(false, animated: false)
                UserDefaults.standard.set(false, forKey:Keys.multiSwitch.rawValue)
            }
        }
        UserDefaults.standard.set(sender.isOn, forKey: Keys.multiSwitch.rawValue)
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

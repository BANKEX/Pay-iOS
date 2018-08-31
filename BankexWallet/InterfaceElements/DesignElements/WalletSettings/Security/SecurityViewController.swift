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
    case isChanged = "isChanged"
}

class SecurityViewController: UITableViewController {
    
    
    
    @IBOutlet weak var openSwitch:UISwitch!
    @IBOutlet weak var sendSwitch:UISwitch!
    @IBOutlet weak var multitaskSwitch:UISwitch!
    static var isEnabled = true
    static var isEnabledMulti = true
    static var isEnabledSend = true    //  Let it be for now
    enum SecuritySections:Int {
        case First = 0,Second
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
    }
    
    func setupNavbar() {
        navigationItem.title = NSLocalizedString("Security", comment: "Security")
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        [openSwitch,sendSwitch].forEach { item in
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
                SecurityViewController.isEnabled = false
            }
        }
        UserDefaults.standard.set(sender.isOn, forKey: Keys.openSwitch.rawValue)
        SecurityViewController.isEnabled = sender.isOn
    }
    
    @IBAction func switchSendFunds(_ sender:UISwitch) {
        if sender.isOn {
            TouchManager.authenticateBioMetrics(reason: "", success: {
                print("Success")
            }) { (error) in
                sender.setOn(false, animated: false)
                UserDefaults.standard.set(false, forKey: Keys.sendSwitch.rawValue)
                SecurityViewController.isEnabledSend = false
            }
        }
        UserDefaults.standard.set(sender.isOn, forKey: Keys.sendSwitch.rawValue)
        SecurityViewController.isEnabledSend = sender.isOn
    }
    
    @IBAction func switchMultitask(_ sender:UISwitch) {
        if sender.isOn {
            TouchManager.authenticateBioMetrics(reason: "", success: {
                print("Success")
            }) { (error) in
                sender.setOn(false, animated: false)
                UserDefaults.standard.set(false, forKey:Keys.multiSwitch.rawValue)
                SecurityViewController.isEnabledMulti = false
            }
        }
        UserDefaults.standard.set(sender.isOn, forKey: Keys.multiSwitch.rawValue)
        SecurityViewController.isEnabledMulti = sender.isOn
    }
    
    
    
    
    
    
    //DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == SecuritySections.First.rawValue ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == SecuritySections.First.rawValue ? NSLocalizedString("UseTouchID", comment: "") : NSLocalizedString("Lock App", comment: "")
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == SecuritySections.First.rawValue ? 67.0 : 54.0
    }
    
    
}

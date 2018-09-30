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
    enum SecuritySections:Int {
        case First = 0,Second
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        [openSwitch,sendSwitch,multitaskSwitch].forEach { $0?.onTintColor = WalletColors.mainColor }
        tableView.tableFooterView = HeaderView()
        tableView.backgroundColor = WalletColors.bgMainColor
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
        openSwitch.isOn = UserDefaults.standard.bool(forKey:Keys.openSwitch.rawValue)
        sendSwitch.isOn = UserDefaults.standard.value(forKey:Keys.sendSwitch.rawValue) as? Bool ?? true
        multitaskSwitch.isOn = UserDefaults.standard.value(forKey:Keys.multiSwitch.rawValue) as? Bool ?? true
    }
    
    
    @IBAction func switchTouchID(_ sender:UISwitch) {
        if sender.isOn {
            TouchManager.authenticateBioMetrics(reason: "", success: {
                UserDefaults.standard.set(true, forKey: Keys.openSwitch.rawValue)
            }) { (error) in
                sender.setOn(false, animated: false)
                UserDefaults.standard.set(false, forKey: Keys.openSwitch.rawValue)
            }
            return
        }
        UserDefaults.standard.set(false, forKey: Keys.openSwitch.rawValue)
    }
    
    @IBAction func switchSendFunds(_ sender:UISwitch) {
        if sender.isOn {
            TouchManager.authenticateBioMetrics(reason: "", success: {
                UserDefaults.standard.set(true, forKey: Keys.sendSwitch.rawValue)
            }) { (error) in
                sender.setOn(false, animated: false)
                UserDefaults.standard.set(false, forKey: Keys.sendSwitch.rawValue)
            }
            return
        }
        UserDefaults.standard.set(false, forKey: Keys.sendSwitch.rawValue)
    }
    
    
    @IBAction func switchMultitask(_ sender:UISwitch) {
        if sender.isOn {
            TouchManager.authenticateBioMetrics(reason: "", success: {
                UserDefaults.standard.set(true, forKey: Keys.multiSwitch.rawValue)
            }) { (error) in
                sender.setOn(false, animated: false)
                UserDefaults.standard.set(false, forKey:Keys.multiSwitch.rawValue)
            }
            return
        }
        UserDefaults.standard.set(false, forKey: Keys.multiSwitch.rawValue)
    }
    
    
    
    
    
    
    //DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == SecuritySections.First.rawValue ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView()
        if SecuritySections.First.rawValue == section {
            headerView.title = NSLocalizedString("UseTouchID", comment: "")
        }else {
            headerView.title = NSLocalizedString("Lock App", comment: "")
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54.0
    }
    
    
}

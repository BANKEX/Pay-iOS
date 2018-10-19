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
    @IBOutlet weak var timerLbl:UILabel!
    enum SecuritySections:Int {
        case First = 0,Second,Third
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        [openSwitch,sendSwitch,multitaskSwitch].forEach { $0?.onTintColor = UIColor.mainColor }
        tableView.tableFooterView = HeaderView()
        tableView.backgroundColor = UIColor.bgMainColor
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
        timerLbl.text = AutoLockService.shared.getState() ?? ""
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

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? AutoLockViewController else { return }
        dest.delegate = self
    }
    
    
    
    //DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SecuritySections.First.rawValue {
            return 2
        }else if section == SecuritySections.Second.rawValue {
            return 1
        }else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            performSegue(withIdentifier: "autoLock", sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView()
        if SecuritySections.First.rawValue == section {
            headerView.title = NSLocalizedString("UseTouchID", comment: "")
        }else if SecuritySections.Second.rawValue == section {
            headerView.title = NSLocalizedString("Lock App", comment: "")
        }else {
            headerView.titleFrame = CGRect(x: 16, y: 0, width: view.bounds.width - 55, height: 54)
            headerView.title = "If enabled the app requires PIN when switching between apps"
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54.0
    }
    
    
}

extension SecurityViewController:AutoLockViewControllerDelegate {
    func didSelect(_ time: String) {
        timerLbl.text = time
    }
}

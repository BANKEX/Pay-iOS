//
//  UITableViewDataSource.swift
//  BankexWallet
//
//  Created by Vladislav on 21.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

extension SettingsViewController {
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSections.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SettingsSections.General.rawValue:
            return 3
        case SettingsSections.Support.rawValue:
            return 2
        case SettingsSections.Community.rawValue:
            return 4
        case SettingsSections.Developer.rawValue:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView()
        switch section {
        case 0: headerView.title = NSLocalizedString("General", comment: "")
        case 1: headerView.title = NSLocalizedString("Support", comment: "")
        case 2: headerView.title = NSLocalizedString("Community", comment: "")
        case 3: headerView.title = NSLocalizedString("DevSettings", comment: "")
        default: break
        }
        return headerView
    }
}

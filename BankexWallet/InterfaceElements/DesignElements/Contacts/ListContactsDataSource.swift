//
//  ListContactsDataSource.swift
//  BankexWallet
//
//  Created by Vladislav on 27.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

extension ListContactsViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            return 1
        }else {
            return sectionsTitles.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredContacts.count
        }else {
            let nameofSection = sectionsTitles[section]
            return (dictContacts[nameofSection]?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier:ContactCell.identifier, for: indexPath) as? ContactCell {
            if isFiltering() {
                cell.contact = filteredContacts[indexPath.row]
            }else {
                guard let currentContacts = dictContacts[sectionsTitles[indexPath.section]] else { return UITableViewCell() }
                cell.contact = currentContacts[indexPath.row]
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering() {
            return ""
        }else {
            return sectionsTitles[section]
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isFiltering() {
            return nil
        }else {
            return sectionsTitles
        }
    }
}

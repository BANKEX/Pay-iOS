//
//  KeysListController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/12/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class KeysListController: UITableViewController {

    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    
    var addresses: [String]?
    var selectedAddress: String?
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addresses = keysService.fullListOfPublicAddresses()
        selectedAddress = keysService.preferredSingleAddress()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        let addressAtIndex = (index < addresses?.count ?? 0) ? addresses?[indexPath.row] : nil
        cell.textLabel?.text = addressAtIndex ?? "Create New Key"
        cell.backgroundColor = UIColor.clear
        if addressAtIndex == selectedAddress {
            cell.imageView?.image = #imageLiteral(resourceName: "icons-checked")
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let newSelectedAddress = addresses?[indexPath.row] else {
            return
        }
        selectedAddress = newSelectedAddress
        keysService.updatePreferred(address: newSelectedAddress)
        tableView.reloadData()
    }

}

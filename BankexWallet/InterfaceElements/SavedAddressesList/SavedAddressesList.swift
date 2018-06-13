//
//  SavedAddressesList.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/13/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol AddressSelection: class {
    func didSelect(address: String)
}

class SavedAddressesList: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let addressesListService: RecipientsAddressesService = RecipientsAddressesServiceImplementation()
    
    var addressesList: [FavoriteModel]?
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView?
    
    weak var selectionAddressDelegate: AddressSelection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressesList = addressesListService.getAllStoredAddresses()
        guard let addressesList = addressesList, !addressesList.isEmpty else {
            emptyView.isHidden = false
            tableView?.isHidden = true
            return
        }
        emptyView.isHidden = true
        tableView?.isHidden = false

        tableView?.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressesList?.count ?? 0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SubtitleCell")
        //let (name, address) = (addressesList?[indexPath.row])!
        let name = addressesList?[indexPath.row].name
        let address = addressesList?[indexPath.row].address
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let address = addressesList?[indexPath.row].address else {
            return
        }
        selectionAddressDelegate?.didSelect(address: address)
    }
}

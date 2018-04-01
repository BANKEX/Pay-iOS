//
//  KeysListController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/12/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class KeysListController: UITableViewController, OpenQRCode {

    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    
    var addresses: [String]?
    var selectedAddress: String?
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addresses = keysService.fullListOfPublicAddresses()
        selectedAddress = keysService.selectedAddress()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "PublicKeyCell", for: indexPath) as! PublicKeyCell
        let addressAtIndex = (index < addresses?.count ?? 0) ? addresses?[indexPath.row] : nil
        cell.configure(withAddress: (addressAtIndex ?? ""), isSelected: addressAtIndex == selectedAddress)
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let newSelectedAddress = addresses?[indexPath.row] else {
            return
        }
        selectedAddress = newSelectedAddress
        keysService.updateSelected(address: newSelectedAddress)
        tableView.reloadData()
    }
    
    // MARK: OpenQRCode
    var address: String = ""
    func openQRCode(for address: String) {
        self.address = address
        performSegue(withIdentifier: "showQRCode", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showQRCode" {
            let controller = segue.destination as? AddressQRCodeController
            controller?.addressToGenerateQR = address
        }
        address = ""
    }

}

//
//  FavoritesListController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 5/11/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol FavoritesHandling: class {
    func editFavorite(with name: String, address: String)
    
    func sendTokenToFavorite(with name: String, address: String)
}

class FavoritesListController: UIViewController,
    UITableViewDelegate,
UITableViewDataSource,
FavoritesHandling {
    
    let favService: RecipientsAddressesService = RecipientsAddressesServiceImplementation()
    var allFavorites:[FavoriteModel]?
    @IBOutlet weak var tableView: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allFavorites = favService.getAllStoredAddresses()
        tableView.reloadData()
    }
    
    @IBAction func unwind(segue:UIStoryboardSegue) { }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? FavoriteInputController {
            controller.selectedFavoriteName = selectedName
            controller.selectedFavoriteAddress = selectedAddress
            selectedName = nil
            selectedAddress = nil
        }
        if let controller = segue.destination as? CreateNewFavoriteController {
            controller.editingContact = true
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFavorites?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesListCell", for: indexPath) as! FavoritesListCell
        cell.configure(with: allFavorites![indexPath.row], selectionDelegate: self)
        return cell
    }


    // MARK:  FavoritesSelection
    var selectedAddress: String?
    var selectedName: String?
    func editFavorite(with name: String, address: String) {
        selectedName = name
        selectedAddress = address
        performSegue(withIdentifier: "showEditContact", sender: self)
    }

    func sendTokenToFavorite(with name: String, address: String) {
        selectedName = name
        selectedAddress = address
        performSegue(withIdentifier: "showSendToken", sender: self)
    }
}

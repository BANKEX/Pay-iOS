//
//  FavouritesListWithCollectionCell.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/5/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol FavoriteSelectionDelegate: class {
    func didSelectFavorite(with name: String, address: String)
    func didSelectAddNewFavorite()
}

class FavouritesListWithCollectionCell: UITableViewCell,
                                        UICollectionViewDelegate,
                                        UICollectionViewDataSource {

    weak var selectionDelegate: FavoriteSelectionDelegate?
    
    let favoritesService: RecipientsAddressesService = RecipientsAddressesServiceImplementation()
    var allFavorites: [(String, String)]?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        allFavorites = favoritesService.getAllStoredAddresses()
    }
    
    // MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + (allFavorites?.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            selectionDelegate?.didSelectAddNewFavorite()
        }
        else if let selected = allFavorites?[indexPath.row - 1] {
            selectionDelegate?.didSelectFavorite(with: selected.0, address: selected.1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row != 0 else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "AddContactCollectionCell", for: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddContactCollectionCell", for: indexPath)
        return cell
    }
}

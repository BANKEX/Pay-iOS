//
//  FavouritesListWithCollectionCell.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/5/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class FavouritesListWithCollectionCell: UITableViewCell,
                                        UICollectionViewDelegate,
                                        UICollectionViewDataSource {

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
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row != 0 else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "AddContactCollectionCell", for: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddContactCollectionCell", for: indexPath)
        return cell
    }
}

//
//  FavoritesCollectionViewCell.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 5/10/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class FavouritesTitleCell: UITableViewCell {
    @IBOutlet weak var showMoreButton: UIButton!
    let favService: RecipientsAddressesService = RecipientsAddressesServiceImplementation()
    let minFavoritesToShow = 1
    override func awakeFromNib() {
        super.awakeFromNib()
        showMoreButton.setTitle((favService.getAllStoredAddresses()?.count ?? 0) < minFavoritesToShow ? "Add Contact" : "See All", for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        showMoreButton.setTitle((favService.getAllStoredAddresses()?.count ?? 0) < minFavoritesToShow ? "Add Contact" : "See All", for: .normal)
    }
}


class FavoritesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shortNameLabel: UILabel!
    
    func configure(with contact: FavoriteModel) {
        let name = contact.name
        nameLabel.text = name
        let firstLetter = (name as NSString).substring(to: 1)
        
        shortNameLabel.text = firstLetter.capitalized
        let color = UIColor.randomDark()
        avatarImageView.backgroundColor = color.withAlphaComponent(0.35)
        shortNameLabel.textColor = color
    }
    
}

class FavoritesListCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shortNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    weak var selectionDelegate: FavoritesHandling?
    
    var name, address: String?
    
    func configure(with contact: FavoriteModel, selectionDelegate: FavoritesHandling) {
        name = contact.name
        address = contact.address
        nameLabel.text = name
        let firstLetter = ((name ?? "") as NSString).substring(to: 1)
        self.selectionDelegate = selectionDelegate
        shortNameLabel.text = firstLetter.capitalized
        let color = UIColor.randomDark()
        avatarImageView.backgroundColor = color.withAlphaComponent(0.35)
        shortNameLabel.textColor = color
        addressLabel.text = address
    }
    
    @IBAction func editContact(sender: Any) {
    selectionDelegate?.editFavorite(with: name ?? "" , address: address ?? "")
    }
    
    @IBAction func sendToken(sender: Any) {
        selectionDelegate?.sendTokenToFavorite(with: name ?? "", address: address ?? "")
    }
}


//
//  WalletCell.swift
//  BankexWallet
//
//  Created by Vladislav on 22.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol WalletSelectedDelegate: class {
    func didSelectWallet(withAddress address: String)
}

class WalletCell: UITableViewCell {
    
    @IBOutlet weak var nameWalletLabel:UILabel!
    @IBOutlet weak var addressWalletLabel:UILabel!
    
    var address: String?
    
    weak var delegate: WalletSelectedDelegate?
    
    static var identifier:String {
        return String(describing: self)
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        prepareAddressLabel()
    }
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        if let address = address {
            delegate?.didSelectWallet(withAddress: address)
        }
    }
    
    func configure(wallet:HDKey) {
        nameWalletLabel.text = wallet.name
        addressWalletLabel.text = getFormattedAddress(wallet.address)
        address = wallet.address
    }
    
    private func getFormattedAddress(_ address: String) -> String {
        let formatted = address[address.startIndex..<address.index(address.startIndex, offsetBy: 10)] + "..." + address[address.index(address.endIndex, offsetBy: -10)..<address.endIndex]
        return String(formatted)
        
    }
    
    func prepareAddressLabel() {
        addressWalletLabel.adjustsFontSizeToFitWidth = true
        addressWalletLabel.numberOfLines = 1
        addressWalletLabel.font = UIFont.systemFont(ofSize: 14.0)
    }

}


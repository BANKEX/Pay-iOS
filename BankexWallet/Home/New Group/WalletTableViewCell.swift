//
//  WalletTableViewCell.swift
//  BankexWallet
//
//  Created by Vladislav on 12.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class WalletTableViewCell: UITableViewCell {
    
    //IBOutlets
    @IBOutlet weak var walletImageView:UIImageView!
    @IBOutlet weak var nameWalletLbl:UILabel!
    @IBOutlet weak var balanceLbl:UILabel!
    @IBOutlet weak var symbolLbl:UILabel!
    
    
    var utilsService:UtilTransactionsService?
    
    var wallet:KeyWalletModel! {
        didSet {
            configureWallet()
        }
    }
    
    
    var token:ERC20TokenModel! {
        didSet {
            configureToken()
        }
    }
    
    
    static let identifier:String = String(describing: WalletTableViewCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDefaultShadow()
        selectionStyle = .none
        layer.cornerRadius = 8.0
        backgroundColor = .white
    }
    
    func configureWallet() {
        nameWalletLbl.text = wallet.name
    }
    
    func configureToken() {
        walletImageView.image = PredefinedTokens(with: token.symbol).image()
        symbolLbl.text = token.symbol.uppercased()
        updateLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateLayout()
    }
    
    func updateLayout() {
        utilsService = token.address.isEmpty ? UtilTransactionsServiceImplementation() :
            CustomTokenUtilsServiceImplementation()
        updateBalance()
    }
    func updateBalance() {
        let selectedAddress = wallet.address
        utilsService?.getBalance(for: token.address, address: selectedAddress) { (result) in
            switch result {
            case .Success(let response):
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                let formattedAmount = Web3.Utils.formatToEthereumUnits(response,
                                                                       toUnits: .eth,
                                                                       decimals: 8,
                                                                       fallbackToScientific: true)
                self.balanceLbl.text = formattedAmount!
            case .Error(let error):
                self.balanceLbl.text = "..."
                
                print("\(error)")
            }
        }
    }

    
}

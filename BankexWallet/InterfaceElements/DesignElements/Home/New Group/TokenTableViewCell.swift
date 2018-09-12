//
//  TokenTableViewCell.swift
//  BankexWallet
//
//  Created by Vladislav on 12.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class TokenTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tokenImageView:UIImageView!
    @IBOutlet weak var balanceToken:UILabel!
    @IBOutlet weak var symbolToken:UILabel!
    @IBOutlet weak var nameToken:UILabel!
    
    static let identifier:String = String(describing: TokenTableViewCell.self)
    let keysService = SingleKeyServiceImplementation()
    
    var token:ERC20TokenModel! {
        didSet {
            configure()
        }
    }
        


    override func awakeFromNib() {
        super.awakeFromNib()
        setupDefaultShadow()
        layer.cornerRadius = 8.0
        selectionStyle = .none
        backgroundColor = .white
    }

    func configure() {
        tokenImageView.image = PredefinedTokens(with: token.symbol).image()
        nameToken.text = token.name
        symbolToken.text = token.symbol.uppercased()
        
        let service: UtilTransactionsService = !token.address.isEmpty ? CustomTokenUtilsServiceImplementation() : UtilTransactionsServiceImplementation()
        service.getBalance(for: token.address, address: keysService.selectedAddress() ?? "") { (result) in
            
            switch result {
            case .Success(let response):
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                let formattedAmount = Web3.Utils.formatToEthereumUnits(response,
                                                                        toUnits: .eth,
                                                                        decimals: 8)
                self.balanceToken.text = formattedAmount!

            case .Error( _):
                self.balanceToken.text = "..."
            }
        }
        
    }
    
}

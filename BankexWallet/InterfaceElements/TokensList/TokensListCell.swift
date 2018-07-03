//
//  TokensListCellNew.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 27.06.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//


import UIKit
import web3swift

class TokensListCell: UITableViewCell {
    
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    
    @IBOutlet weak var tokenIconImageView: UIImageView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountInDollarLabel: UILabel!
    @IBOutlet weak var tokenShortNameLabel: UILabel!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    
    @IBOutlet weak var deleteButton: TokensListCellButton!
    @IBOutlet weak var tokensListCellInfoButton: TokensListCellButton!
    
    var selectedToken: ERC20TokenModel?
    let keysService: SingleKeyService  = SingleKeyServiceImplementation()
    var didChangeToken = false
    var didCallCompletion = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with token: ERC20TokenModel, isSelected: Bool, isEtherCoin: Bool, isEditing: Bool) {
        
        // Just copypasted
        if token.address != selectedToken?.address {
            self.amountLabel.text = "..."
        }
        selectedToken = token
        if !didCallCompletion {
            didChangeToken = true
        }
        let service: UtilTransactionsService = !token.address.isEmpty ? CustomTokenUtilsServiceImplementation() : UtilTransactionsServiceImplementation()
        
        didCallCompletion = false
        //
        
        service.getBalance(for: token.address, address: keysService.selectedAddress() ?? "") { (result) in
            self.didCallCompletion = true
            guard !self.didChangeToken else {
                return
            }
            
            switch result {
            case .Success(let response):
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                let formattedAmount = Web3 .Utils.formatToEthereumUnits(response,
                                                                       toUnits: .eth,
                                                                       decimals: 4)
                self.amountLabel.text = formattedAmount!
                // TODO: convert to $
                self.amountInDollarLabel.text = "$\(formattedAmount!) at the rate of Binance"
            case .Error( _):
                self.amountLabel.text = "..."
                
            }
        }
        
        // Cell is different for first and other positions
        topConstraint?.constant = isEtherCoin ? 15 : 5
        
        //configure labels
        tokenShortNameLabel?.text = token.symbol.uppercased()
        walletNameLabel?.text = keysService.selectedWallet()?.name
        // TODO: Не вполне ясно что за адрес - кошелька или токена?
        //keyLabel?.text = token.address.lowercased()
        keyLabel?.text = token.address
        
        //configure image and buttons
        tokenIconImageView.image = PredefinedTokens(with: token.symbol).image()
        deleteButton.layer.cornerRadius = deleteButton.bounds.size.width / 2
        deleteButton.isHidden = isEditing ? false : true
        
        deleteButton.setTitle(token.address, for: .normal)
        deleteButton.titleLabel?.isHidden = true
        
        deleteButton.chosenToken = token
        tokensListCellInfoButton.chosenToken = token
    }
}

class TokensListCellButton: UIButton {
    var chosenToken: ERC20TokenModel? = nil
}


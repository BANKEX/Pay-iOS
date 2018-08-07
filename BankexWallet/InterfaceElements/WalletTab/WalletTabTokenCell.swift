//
//  WalletTabTokenCell.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 23.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class WalletTabTokenCell: UITableViewCell {
    
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    
    @IBOutlet weak var tokenIconImageView: UIImageView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountInDollarLabel: UILabel!
    @IBOutlet weak var tokenShortNameLabel: UILabel!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    
    @IBOutlet weak var deleteButtonBottom: TokensListCellButton!
    @IBOutlet weak var deleteButtonTop: TokensListCellButton!
    @IBOutlet weak var tokensListCellInfoButton: TokensListCellButton!
    
    var selectedToken: ERC20TokenModel?
    let keysService: SingleKeyService  = SingleKeyServiceImplementation()
    var didChangeToken = false
    var didCallCompletion = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with token: ERC20TokenModel, isSelected: Bool, isEtherCoin: Bool, isEditing: Bool, withConversionRate: Double = 0) {
        
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
                // convert to $
                let convertedAmount = withConversionRate == 0.0 ? "No data from CryptoCompare" : "$\(withConversionRate * Double(formattedAmount!)!) at the rate of CryptoCompare"
                self.amountInDollarLabel.text = convertedAmount
            case .Error( _):
                self.amountLabel.text = "..."
                
            }
        }
        
        // Cell is different for first and other positions
        topConstraint?.constant = isEtherCoin ? 20 : 7
        
        //configure labels
        tokenShortNameLabel?.text = token.symbol.uppercased()
        walletNameLabel?.text = keysService.selectedWallet()?.name
        // TODO: Не вполне ясно что за адрес - кошелька или токена?
        //keyLabel?.text = token.address.lowercased()
        keyLabel?.text = token.address
        
        //configure image and buttons
        tokenIconImageView.image = PredefinedTokens(with: token.symbol).image()
        deleteButtonBottom.layer.cornerRadius = deleteButtonBottom.bounds.size.width / 2
        deleteButtonBottom.isHidden = isEditing ? false : true
        deleteButtonTop.layer.cornerRadius = deleteButtonTop.bounds.size.width / 2
        deleteButtonTop.isHidden = isEditing ? false : true
        
        deleteButtonBottom.setTitle(token.address, for: .normal)
        deleteButtonBottom.titleLabel?.isHidden = true
        deleteButtonTop.setTitle(token.address, for: .normal)
        deleteButtonTop.titleLabel?.isHidden = true
        
        deleteButtonBottom.chosenToken = token
        deleteButtonTop.chosenToken = token
        
        tokensListCellInfoButton.chosenToken = token
        tokensListCellInfoButton.amount = self.amountLabel.text
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        self.amountLabel.text = ""
        self.amountInDollarLabel.text = ""
        self.tokenShortNameLabel.text = ""
        self.walletNameLabel.text = ""
        self.keyLabel.text = ""
        self.tokenIconImageView.image = UIImage(named: "AppIcon")
    }
}

class TokensListCellButton: UIButton {
    var chosenToken: ERC20TokenModel? = nil
    var amount: String? = nil
}

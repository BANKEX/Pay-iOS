//
//  TokensListCell.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/15/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class TokensListCell: UITableViewCell {
    
    @IBOutlet weak var selectedTokenImageView: UIImageView?
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    
    @IBOutlet weak var tokenNameLabel: UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var theOnlyBackgroundView: UIView?
    @IBOutlet weak var lastCellBackgroundView: UIView?
    @IBOutlet weak var firstCellBackgroundView: UIView?
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var separatorView: UIView?
    @IBOutlet weak var tokenIconImageView: UIImageView!
    
    var selectedToken: ERC20TokenModel?
    let keysService: SingleKeyService  = SingleKeyServiceImplementation()
    var didChangeToken = false
    var didCallCompletion = true
    
    func configure(with token: ERC20TokenModel, isSelected: Bool, isFirstCell: Bool, isLastCell: Bool) {
        if token.address != selectedToken?.address {
            self.amountLabel.text = "..."
        }
        selectedToken = token
        if !didCallCompletion {
            didChangeToken = true
        }
        let service: UtilTransactionsService = !token.address.isEmpty ? CustomTokenUtilsServiceImplementation() : UtilTransactionsServiceImplementation()
        
        didCallCompletion = false
        service.getBalance(for: token.address, address: keysService.selectedAddress() ?? "") { (result) in
            self.didCallCompletion = true
            guard !self.didChangeToken else {
                return
            }
            
            switch result {
            case .Success(let response):
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                let formattedAmount = Web3.Utils.formatToEthereumUnits(response,
                                                                       toUnits: .eth,
                                                                       decimals: 4)
                self.amountLabel.text = formattedAmount!
            case .Error( _):
                self.amountLabel.text = "..."
                
            }
        }
        theOnlyBackgroundView?.isHidden = !(isFirstCell && isLastCell)
        lastCellBackgroundView?.isHidden = isFirstCell
        firstCellBackgroundView?.isHidden = isLastCell
        separatorView?.isHidden = isLastCell
        checkmarkImage.isHidden = !isSelected
        symbolLabel.text = token.symbol
        tokenNameLabel?.text = token.name
        tokenIconImageView.image = PredefinedTokens(with: token.symbol).image()
        
    }
    
    
    
    func configure(with token: ERC20TokenModel) {
    }
    
}

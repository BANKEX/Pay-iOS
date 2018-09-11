//
//  EthereumTableVIewCell.swift
//  BankexWallet
//
//  Created by Vladislav on 11.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift


class EthereumTableVIewCell: UITableViewCell {
    
    @IBOutlet weak var nameWalletLbl:UILabel!
    @IBOutlet weak var balanceLbl:UILabel!
    @IBOutlet weak var symbolLbl:UILabel!
    
    let keyService = SingleKeyServiceImplementation()
    
    var utilsService: UtilTransactionsService!
    let tokensService = CustomERC20TokensServiceImplementation()
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        updateLayout()
        backgroundColor = .white
        layer.cornerRadius = 8.0
        [balanceLbl,symbolLbl].forEach { $0?.textColor = WalletColors.mainColor }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateLayout()
    }
    
    func updateLayout() {
        self.balanceLbl.text = "..."
        utilsService = tokensService.selectedERC20Token().address.isEmpty ? UtilTransactionsServiceImplementation() :
            CustomTokenUtilsServiceImplementation()
        updateBalance()
        
        // Initialization code
//        tokenIconImageView.image = PredefinedTokens(with: tokensService.selectedERC20Token().symbol).image()
        nameWalletLbl.text = keyService.selectedWallet()?.name
        symbolLbl.text = tokensService.selectedERC20Token().symbol.uppercased()
        
    }
    func updateBalance() {
        guard let selectedAddress = keyService.selectedAddress() else {
            return
        }
        utilsService.getBalance(for: tokensService.selectedERC20Token().address, address: selectedAddress) { (result) in
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



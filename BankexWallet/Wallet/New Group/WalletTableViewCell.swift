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
    @IBOutlet weak var fillView:UIView!
    
    
    var utilsService = UtilTransactionsServiceImplementation()
    let keyService = SingleKeyServiceImplementation()
    
    
    static let identifier:String = String(describing: WalletTableViewCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fillView.setupDefaultShadow()
        selectionStyle = .none
        fillView.layer.cornerRadius = 8.0
        backgroundColor = WalletColors.bgMainColor
        setData()
    }
    
    func setData() {
        keyService.updateSelectedWallet()
        updateLayout()
        if let wallet = keyService.selectedWallet() {
            nameWalletLbl.text = wallet.name
            walletImageView.image = PredefinedTokens.Ethereum.image()
            symbolLbl.text = "ETH"
            UserDefaults.saveData(string: wallet.name)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setData()
        updateLayout()
    }
    
    func updateLayout() {
        updateBalance()
    }
    
    
    func updateBalance() {
        guard let wallet = keyService.selectedWallet() else { return }
        let selectedAddress = wallet.address
        utilsService.getBalance(for: "", address: selectedAddress) { (result) in
            switch result {
            case .Success(let response):
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                let formattedAmount = Web3.Utils.formatToEthereumUnits(response,
                                                                       toUnits: .eth,
                                                                       decimals: 8,
                                                                       fallbackToScientific: true)
                DispatchQueue.main.async {
                   self.balanceLbl.text = formattedAmount!
                    UserDefaults.saveData(string: formattedAmount!)
                }
            case .Error(let error):
                self.balanceLbl.text = "..."
                
                print("\(error)")
            }
        }
    }

    
}

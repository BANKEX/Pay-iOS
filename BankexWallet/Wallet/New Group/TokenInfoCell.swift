//
//  TokenInfoCell.swift
//  BankexWallet
//
//  Created by Vladislav on 14.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class TokenInfoCell: UITableViewCell {
    
    @IBOutlet weak var headerLabel:UILabel!
    @IBOutlet weak var valueLabel:UILabel!
    
    let conversionService = FiatServiceImplementation()
    static let identifier:String = String(describing: TokenInfoCell.self)
    var selectedIndex = 0
    var selectedToken:ERC20TokenModel? {
        didSet {
            setData()
        }
    }
    var numberFormatter:NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = "$"
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 5
        return numberFormatter
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    fileprivate func setData() {
        let tokenInfoRow = TokenInfoRaws(rawValue: selectedIndex)!
        headerLabel.text = tokenInfoRow.string()
        guard let token = selectedToken else { return }
        switch tokenInfoRow {
        case .address:
            valueLabel.text = token.address.formattedAddrToken()
        case .decimals:
            valueLabel.text = token.decimals
        case .currency:
            conversionService.updateConversionRate(for: selectedToken!.symbol.uppercased()) { rate in
                self.valueLabel.text = self.numberFormatter.string(from: NSNumber(value:rate))
            }
        }
    }
}

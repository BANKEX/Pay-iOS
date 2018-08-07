//
//  WalletIsReadyCell.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 28.05.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol CloseNewWalletNotifDelegate: class {
    func didClose()
}

class WalletIsReadyCell: UITableViewCell {

    weak var delegate: CloseNewWalletNotifDelegate?
    
    
    @IBAction func close(_ sender: Any) {
        delegate?.didClose()
    }
    
}

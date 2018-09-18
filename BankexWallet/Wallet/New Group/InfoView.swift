//
//  InfoView.swift
//  BankexWallet
//
//  Created by Vladislav on 18.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol InfoViewDelegate:class {
    func backButtonTapped()
}

class InfoView: UIView {
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var balanceLabel:UILabel!
    @IBOutlet weak var rateLabel:UILabel!
    @IBOutlet weak var addrWallet:UILabel!
    @IBOutlet weak var nameWallet:UILabel!
    @IBOutlet weak var nameTokenLabel:UILabel!
    
    weak var delegate:InfoViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = WalletColors.mainColor
    }
    
    @IBAction func stepBack() {
        delegate?.backButtonTapped()
    }
}

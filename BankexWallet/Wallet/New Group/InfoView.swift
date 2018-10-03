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
    func deleteButtonTapped()
}

class InfoView: UIView {
    
    enum InfoState {
        case Eth,Token
    }
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var balanceLabel:UILabel!
    @IBOutlet weak var rateLabel:UILabel!
    @IBOutlet weak var addrWallet:UILabel!
    @IBOutlet weak var nameWallet:UILabel!
    @IBOutlet weak var nameTokenLabel:UILabel!
    @IBOutlet weak var deleteButton:UIButton?
    @IBOutlet weak var tokenNameLabel:UILabel?
    
    weak var delegate:InfoViewDelegate?
    var state:InfoState = .Eth {
        didSet {
            if state == .Eth {
                deleteButton?.isHidden = true
                tokenNameLabel?.isHidden = true
                nameWallet.isHidden = false
                addrWallet.isHidden = false
                titleLabel?.text = "Wallet Information"
            }else {
                deleteButton?.isHidden = false
                tokenNameLabel?.isHidden = false
                nameWallet.isHidden = true
                addrWallet.isHidden = true
                titleLabel?.text = "Token Information"
            }
        }
    }
    
    var isEmptyBalance:Bool {
        return balanceLabel.text == "0"
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = WalletColors.mainColor
    }
    
    @IBAction func stepBack() {
        delegate?.backButtonTapped()
    }
    
    @IBAction func deleteToken() {
        delegate?.deleteButtonTapped()
    }
}

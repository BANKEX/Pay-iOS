//
//  HeaderView.swift
//  BankexWallet
//
//  Created by Vladislav on 30.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    
    public var title:String = "" {
        didSet{
           updateUI()
        }
    }
    var label:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width:UIScreen.main.bounds.width, height: 54.0))
        prepareView()
        prepareTitleLabel()
        return
    }
    
    private func prepareView() {
        self.backgroundColor = WalletColors.bgMainColor

    }
    
    private func prepareTitleLabel() {
        label = UILabel(frame: CGRect(x: 16.0, y: 32.0, width: self.frame.width, height: 20))
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textColor = WalletColors.blackColor.withAlphaComponent(0.5)
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateUI() {
        label.text = title
        
    }
    
    

}

//
//  TokenArrow.swift
//  BankexWallet
//
//  Created by Vladislav on 10/12/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import UIKit

class TokenArrow: UIView {
    
    @IBOutlet private var symbolTokenLabel: UILabel!
    @IBOutlet private var contentView:UIView?
    
    public var tokenSymbol:String = "" {
        didSet {
            if oldValue != tokenSymbol {
                updateUI()
            }
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TokenArrow", owner: self, options: nil)
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
    private func updateUI() {
        symbolTokenLabel.text = tokenSymbol.uppercased()
    }
    
    
}



//
//  ClipboardView.swift
//  BankexWallet
//
//  Created by Vladislav on 08/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import UIKit

class ClipboardView:UIView {
    //API
    public var title:String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    public var color:UIColor = WalletColors.clipboardColor {
        didSet {
            backgroundColor = color
        }
    }
    
    private var titleLabel:UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setData()
    }
    
    func setData() {
        titleLabel = UILabel(frame: CGRect(x: 0, y: 14, width: self.bounds.width, height: 30))
        titleLabel.textAlignment = .center
        titleLabel.textColor = WalletColors.bgMainColor
        titleLabel.font = UIFont.systemFont(ofSize: 15.0)
        titleLabel.text = title
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showClipboard() {
        UIView.animate(withDuration: 0.7, animations: {
            self.frame.origin.y = self.superview!.bounds.height - self.bounds.height
        }) { _ in
            self.hideClipboard()
        }
    }
    
    func hideClipboard() {
        UIView.animate(withDuration: 0.7, delay: 0.5, options: .curveEaseInOut, animations: {
            self.frame.origin.y = self.superview!.bounds.maxY
        })
    }
    
    
}

//
//  BackButtonView.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 05/12/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class BackButtonView: UIView {
    
    private static let nib = UINib(nibName: "BackButtonView", bundle: nil)
    
    class func create(action: @escaping (BackButtonView) -> Void) -> BackButtonView {
        let view = loadFromNib()
        view.action = action
        
        return view
    }
    
    class func loadFromNib() -> BackButtonView {
        return self.nib.instantiate(withOwner: nil, options: nil).first as! BackButtonView
    }
    
    open var action: ((BackButtonView) -> Void)?
    
    @IBAction func tap() {
        action?(self)
    }
}

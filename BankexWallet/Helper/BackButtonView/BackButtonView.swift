//
//  BackButtonView.swift
//  BankexWallet
//
//  Created by Oleg Kolomyitsev on 05/12/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class BackButtonView: UIControl {
    
    @IBOutlet var label: UILabel!
    
    private static let nib = UINib(nibName: "BackButtonView", bundle: nil)
    
    class func create(_ target: Any?,
                      action: Selector,
                      for controlEvents: UIControl.Event = .touchUpInside) -> BackButtonView {
        
        let view = loadFromNib()
        view.addTarget(target, action: action, for: controlEvents)
        
        return view
    }
    
    class func loadFromNib() -> BackButtonView {
        return self.nib.instantiate(withOwner: nil, options: nil).first as! BackButtonView
    }
    
}

//
//  searchFooter.swift
//  BankexWallet
//
//  Created by Vladislav on 02.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class SearchFooter:UIView {
    fileprivate var label = UILabel()
    
    //MARK: - Lifecircle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    
    fileprivate func setupView() {
        backgroundColor = WalletColors.mainColor
        self.alpha = 0.0
        label.textAlignment = .center
        label.tintColor = .white
        label.textColor = .white
        self.addSubview(label)
    }
    
    override func draw(_ rect: CGRect) {
        label.frame = bounds
    }
    
    //Animations
    
    fileprivate func show() {
        UIView.animate(withDuration: 0.7) { [unowned self] in
            self.alpha = 1.0
        }
    }
    
    fileprivate func hide() {
        UIView.animate(withDuration: 0.7) { [unowned self] in
            self.alpha = 0.0
        }
    }
    
    
}

extension SearchFooter {
    //API
    
    func establishNotFiltering() {
        label.text = ""
        hide()
    }
    
    func establishFiltering(filteringCount:Int,total:Int) {
        if filteringCount == total {
            establishNotFiltering()
        }else if filteringCount == 0 {
            label.text = "No items match your query"
            show()
        }else {
            label.text = "Filtering \(filteringCount) of \(total)"
            show()
        }
    }
}

//
//  HeaderView.swift
//  BankexWallet
//
//  Created by Vladislav on 30.09.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    //API
    public var title:String = "" {
        didSet{
           updateUI()
        }
    }
    
    public var titleFrame:CGRect? {
        didSet {
            if titleFrame != nil {
                label.frame = titleFrame!
            }
        }
    }
    
    public var textColor:UIColor = UIColor.blackColor.withAlphaComponent(0.5) {
        didSet {
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
        self.backgroundColor = UIColor.bgMainColor

    }
    
    private func prepareTitleLabel() {
        label = UILabel(frame: CGRect(x: 16.0, y: 32.0, width: self.frame.width, height: 20))
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textColor = UIColor.blackColor.withAlphaComponent(0.5)
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateUI() {
        label.text = title
        label.textColor = self.textColor
    }
    
    

}

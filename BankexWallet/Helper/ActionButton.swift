//
//  ActionButton.swift
//  BankexWallet
//
//  Created by Vladislav on 18.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit


class ActionButton:UIButton {
    
    var label:UILabel!
    var imageV:UIImageView!
    var title:String! {
        didSet {
            layoutTitle()
        }
    }
    var image:String! {
        didSet {
            layoutImage()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.label.alpha = 0.2
                self.imageV.alpha = 0.2
            }else {
                UIView.animate(withDuration: 0.5) {
                    self.label.alpha = 1.0
                    self.imageV.alpha = 1.0
                }
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title = ""
        titleLabel?.isHidden = true
        backgroundColor = .white
        layer.cornerRadius = 8.0
        setupDefaultShadow()
        layoutTitle()
        layoutImage()
    }
    
    private func layoutTitle() {
        guard let title = title else { return }
        label = UILabel()
        label.text = title
        label.textColor = title == "Send" ? WalletColors.sendColor : WalletColors.receiveColor
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 14, width: self.bounds.width, height: 14.0)
        self.addSubview(label)
    }
    
    private func layoutImage() {
        guard let image = image else { return }
        imageV = UIImageView()
        imageV.image = UIImage(named:image)
        imageV.frame = CGRect(x: 20.0, y: 14.0, width: 14.0, height: 14.0)
        self.addSubview(imageV)
    }
    
    
    
}

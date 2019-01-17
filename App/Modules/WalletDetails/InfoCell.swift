//
//  InfoCell.swift
//  BankexWallet
//
//  Created by Vladislav on 27/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class InfoCell: UITableViewCell {
    
    var infoState:InfoState! {
        didSet {
            guard infoState != nil else { return }
            updateUI()
        }
    }
    
    @IBOutlet weak var imageInfo:UIImageView?
    @IBOutlet weak var titleLabel:UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .disclosureIndicator
        backgroundColor = .white
    }
    
    func updateUI() {
        imageInfo?.image = infoState.image
        titleLabel?.text = infoState.title
    }
    
}

enum InfoState:Int {
    case export = 0, rename, delete
    
    var title:String {
        switch self {
        case .delete: return "Delete Wallet"
        case .export: return "Export Private Key"
        case .rename: return "Rename Wallet"
        }
    }
    
    var image:UIImage {
        switch self {
        case .delete: return  UIImage(named:"Bluetooth")!
        case .export: return UIImage(named:"KeyIcon")!
        case .rename: return UIImage(named:"PenIcon")!
        }
    }
}

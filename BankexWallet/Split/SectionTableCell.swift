//
//  SectionTableCell.swift
//  BankexWallet
//
//  Created by Vladislav on 24/10/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

enum Section:Int {
    case wallet = 0,history,contacts,settings
    
    var title:String {
        switch self {
        case .wallet: return "Wallet"
        case .history: return "History"
        case .contacts: return "Contacts"
        case .settings: return "Settings"
        }
    }
    
    var image:UIImage {
        switch self {
        case .wallet: return UIImage(named:"Icon 1")!
        case .history: return UIImage(named:"History outline")!
        case .contacts: return UIImage(named:"Icon 3")!
        case .settings: return UIImage(named:"Icon 4.1")!
        }
    }
}

class SectionTableCell: UITableViewCell {
    
    @IBOutlet weak var imageSection:UIImageView?
    @IBOutlet weak var titleSection:UILabel?
    
    var section:Section! {
        didSet {
            guard section != nil else { return }
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            backgroundColor = UIColor.mainColor
            titleSection?.textColor = .white
            imageSection?.changeColor(.white)
        }else {
            backgroundColor = UIColor.white
            titleSection?.textColor = UIColor.importColor
            imageSection?.changeColor(UIColor.importColor)
        }
    }
    
    func updateUI() {
        titleSection?.text = section.title
        //Stupid image
        if section.title == "History" {
            imageSection?.contentMode = .scaleAspectFit
        }
        imageSection?.image = section.image
    }
    
}

//
//  AddressCell.swift
//  BankexWallet
//
//  Created by Alexander Vlasov on 29.01.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import UIKit

class AddressCell: UITableViewCell {
    @IBOutlet weak var addressLabel: SRCopyableLabel!
}

class SRCopyableLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        isUserInteractionEnabled = true
    }

    override var canBecomeFirstResponder: Bool { get{
        return true
        }
    }
    
}

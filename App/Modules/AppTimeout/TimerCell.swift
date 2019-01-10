//
//  TimerCell.swift
//  BankexWallet
//
//  Created by Vladislav on 18/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class TimerCell: UITableViewCell {
    
    @IBOutlet weak var timerLabel:UILabel!
    @IBOutlet weak var doneImage:UIImageView!
    
    var isCurrentCell:Bool {
        return (AutoLockService.shared.getState() ?? "") == timerLabel.text!
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            doneImage.show()
        }
    }
    
    func setData(_ time:String) {
        timerLabel.text = LocalizedStrings.timeout(time: time)
        isCurrentCell ? doneImage.show() : doneImage.hide()
    }
    
}

private extension TimerCell {
    
    struct LocalizedStrings {
        static func timeout(time: String) -> String {
            return String(format: NSLocalizedString("Timeout", tableName: "AppTimeout", comment: ""), time)
        }
    }
}

//
//  PublicKeyCell.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina (Agoda) on 3/13/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol OpenQRCode: class {
    func openQRCode(for address: String)
}

class PublicKeyCell: UITableViewCell {

    @IBOutlet weak var qrCodeButton: UIButton!
    @IBOutlet weak var checkedIcon: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!

    weak var delegate: OpenQRCode?
    var currentAddress = ""
    func configure(withAddress: String, isSelected: Bool) {
        checkedIcon.isHidden = !isSelected
        addressLabel.text = withAddress
        currentAddress = withAddress
    }
    
    @IBAction func createQrCode(_ sender: Any) {
        delegate?.openQRCode(for: currentAddress)
    }
}

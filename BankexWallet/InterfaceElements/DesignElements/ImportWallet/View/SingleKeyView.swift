//
//  SingleKeyView.swift
//  BankexWallet
//
//  Created by Vladislav on 19.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol SingleKeyViewDelegate:class {
    func scanDidTapped(_ scan:UIButton)
    func bufferDidTapped()
    func tfDidBeginEditing(_ textField:UITextField)
    func tfDidEndEditing(_ textField:UITextField)
    func tfShouldReturn(_ textField:UITextField) -> Bool
}

class SingleKeyView:UIView,UITextFieldDelegate {
    
    @IBOutlet weak var nameWalletTextField:UITextField!
    
    
    weak var delegate:SingleKeyViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameWalletTextField.delegate = self
        nameWalletTextField.autocorrectionType = .no
    }
    
    @IBAction func scanTapped(_ sender:UIButton) {
        delegate?.scanDidTapped(sender)
    }
    
    @IBAction func textFromBuffer(_ sender:Any) {
        delegate?.bufferDidTapped()
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.tfDidBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.tfDidEndEditing(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.tfShouldReturn(textField)
        return true
    }
    
}

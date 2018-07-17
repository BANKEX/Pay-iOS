//
//  WalletBIP32Controller.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class WalletBIP32Controller: UIViewController,UITextFieldDelegate,ScreenWithContentProtocol {
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var importButton:UIButton!
    @IBOutlet var textFields:[UITextField]!
    @IBOutlet var separators:[UIView]!
    @IBOutlet weak var separator1:UIView!
    @IBOutlet weak var passwordTextField:UITextField!
    @IBOutlet weak var repeatPasswordTextField:UITextField!
    
    //MARK: - Properties
    let service = HDWalletServiceImplementation()

    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        importButton.isEnabled = false
        textFields.forEach { $0.delegate = self }
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Methods
    func clearTextFields() {
        textFields.forEach {
            $0.text = ""
        }
        view.endEditing(true)
    }
    
    @objc func keyboardHide(_ notification:Notification) {
        //TODO
    }
    
    @objc func keyboardShow(_ notification:Notification) {
        //TODO
    }
    
    //MARK: - IBActions
    @IBAction func changeVisibility(_ sender:Any) {
        //TODO
    }
    
    //MARK: - Delegate_TextField
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        textField.returnKeyType = importButton.isEnabled ? .done : .next
        let index = textFields.index(of: textField) ?? 0
        separators[index].backgroundColor = WalletColors.blueText.color()
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = textFields.index(of: textField) ?? 0
        let currentSeparator = separators[index]
        currentSeparator.backgroundColor = WalletColors.greySeparator.color()
        
        guard textField == passwordTextField || textField == repeatPasswordTextField else { return  }
        
        if !(passwordTextField.text?.isEmpty ?? true) && !(repeatPasswordTextField.text?.isEmpty ?? true) && passwordTextField.text != repeatPasswordTextField.text {
            let indexPswTF = textFields.index(of: passwordTextField) ?? 0
            let indexRepeatPswTF = textFields.index(of: repeatPasswordTextField) ?? 0
            separators[indexPswTF].backgroundColor = WalletColors.errorRed.color()
            separators[indexRepeatPswTF].backgroundColor = WalletColors.errorRed.color()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done && importButton.isEnabled {
            //Create Wallet
        }else if textField.returnKeyType == .next {
            let indexTF = textFields.index(of: textField) ?? 0
            let nextIndex = (textFields.count - 1) == indexTF ? 0 : indexTF + 1
            textFields[nextIndex].becomeFirstResponder()
        }else {
            view.endEditing(true)
        }
        return true
    }
    
    

}

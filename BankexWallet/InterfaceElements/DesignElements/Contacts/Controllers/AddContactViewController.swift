//
//  AddContactViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 26.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import AVFoundation
import web3swift

class AddContactViewController: BaseViewController,UITextFieldDelegate {
    
    @IBOutlet weak var nameContactTextField:UITextField!
    @IBOutlet weak var addressTextField:UITextField!
    @IBOutlet var textFields:[UITextField]!
    @IBOutlet weak var pasteButton:UIButton!
    @IBOutlet weak var doneButton:UIButton!
    
    
    
    enum State {
        case noAvailable,available
    }
    
    var isEmptyName:Bool {
        guard let nameText = nameContactTextField.text else { return true }
        return nameText.isEmpty
    }
    var isEmptyAddress:Bool {
        guard let addr = addressTextField.text else { return true }
        return addr.isEmpty
    }
    var state:State = State.noAvailable {
        didSet {
            switch state {
            case .available:
                doneButton.backgroundColor = WalletColors.mainColor
                doneButton.isEnabled = true
            case .noAvailable:
                doneButton.backgroundColor = WalletColors.disableColor
                doneButton.isEnabled = false
            }
        }
    }
    var service = RecipientsAddressesServiceImplementation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        state = .noAvailable
        navigationController?.navigationBar.barTintColor = WalletColors.mainColor
        navigationController?.navigationBar.tintColor = .white
        UIApplication.shared.statusBarView?.backgroundColor = WalletColors.mainColor
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameContactTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = WalletColors.mainColor
        UIApplication.shared.statusBarView?.backgroundColor = .white
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearInfo()
        state = .noAvailable
        //self.dismiss(animated: false, completion: nil)
        //self.removeFromParentViewController()
    }
    
    
    func clearInfo() {
        [nameContactTextField,addressTextField].forEach { tf in tf?.text = "" }
    }
    
    func setupTextFields() {
        [addressTextField,nameContactTextField].forEach { tf in
            tf?.delegate = self
            tf?.autocorrectionType = .no
        }
        nameContactTextField.autocapitalizationType = .none
    }
    
    
    @IBAction func done() {
//        if firstNameTextField.text == nil && lastNameTextField.text != nil && lastNameTextField.text != "" {
//            firstNameTextField.text = ""
//        }
//        if lastNameTextField.text == nil && firstNameTextField.text != nil && firstNameTextField.text != "" {
//            lastNameTextField.text = ""
//        }
//
//        guard let firstName = firstNameTextField?.text,let lastName = lastNameTextField?.text,let address = addressTextField?.text else { return }
//        guard let ethAddress = EthereumAddress(addressTextField?.text ?? "") else {
//            showAlert(with: "Incorrect address", message: "Please enter valid address")
//            return
//        }
//        service.store(address: address, with: firstName,lastName: lastName , isEditing: false) { (error) in
//            if error?.localizedDescription == "Address already exists in the database" {
//                self.showAlert(with: "Same Address", message: "Address already exists in your contacts")
//                return
//            } else if error?.localizedDescription == "Name already exists in the database" {
//                self.showAlert(with: "Same Name", message: "Name already exists in your contacts")
//                return
//            } else if error != nil {
//                return
//            } else {
//                self.navigationController?.popToRootViewController(animated: true)
//            }
//
//        }
        
        
    }
    
    @objc func removeBecomeResponser() {
        [addressTextField,nameContactTextField].forEach { tf in
            tf?.resignFirstResponder()
        }
    }
    
    
    
    
    @IBAction func importFromBuffer(_ sender:Any) {
        if let text = UIPasteboard.general.string {
            addressTextField?.text = text
            addressTextField.becomeFirstResponder()
        }
    }
    
    func showAlert(with title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.returnKeyType = state == .available ? .done : .next
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        state = !isEmptyName && !isEmptyAddress ? .available : .noAvailable
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = (textField.text ?? "") as NSString
        let futureString = currentString.replacingCharacters(in: range, with: string) as String
        switch textField {
        case nameContactTextField:
            state = (!futureString.isEmpty && !isEmptyAddress) ? .available : .noAvailable
        case addressTextField:
            state = (!futureString.isEmpty && !isEmptyName) ? .available : .noAvailable
        default:
            state = .noAvailable
        }
        textField.returnKeyType = state == .available ? .done : .next
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField.returnKeyType == .done else {
            guard let currentIndex = textFields.index(of: textField) else { return false }
            var nextIndex:Int
            nextIndex = textField == addressTextField ? 0 : currentIndex + 1
            textFields[nextIndex].becomeFirstResponder()
            return true
        }
        done()
        return true
    }
}

extension AddContactViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //TODO
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //TODO
    }
}




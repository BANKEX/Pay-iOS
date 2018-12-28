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

protocol AddContactViewControllerDelegate:class {
    func didSave()
}

class AddContactViewController: BaseViewController,UITextFieldDelegate {
    
    @IBOutlet weak var nameContactTextField:UITextField!
    @IBOutlet weak var addressTextField:UITextField!
    @IBOutlet var textFields:[UITextField]!
    @IBOutlet weak var pasteButton:UIButton!
    @IBOutlet weak var doneButton:UIButton!
    
    weak var delegate:AddContactViewControllerDelegate?
    
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
                doneButton.backgroundColor = UIColor.mainColor
                doneButton.isEnabled = true
            case .noAvailable:
                doneButton.backgroundColor = UIColor.disableColor
                doneButton.isEnabled = false
            }
        }
    }
    var service = ContactService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func addCancelButtonIfNeed() {
        let cancel = UIButton(type: .system)
        cancel.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        cancel.setTitleColor(UIColor.mainColor, for: .normal)
        cancel.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancel.addTarget(self, action: #selector(fadeOut), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancel)
    }
    func addSaveButtonIfNeed() {
        let save = UIButton(type: .system)
        save.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        save.setTitleColor(UIColor.mainColor, for: .normal)
        save.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        save.addTarget(self, action: #selector(done), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: save)
    }
    
    @objc func fadeOut() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        state = .noAvailable
        navigationController?.navigationBar.barTintColor = UIDevice.isIpad ? .white : UIColor.mainColor
        navigationController?.navigationBar.tintColor = .white
        UIApplication.shared.statusBarView?.backgroundColor = UIDevice.isIpad ? .clear : UIColor.mainColor
        UIApplication.shared.statusBarStyle = UIDevice.isIpad ? .default : .lightContent
        doneButton.isHidden = UIDevice.isIpad ? true : false
        title = UIDevice.isIpad ? "New Contact" : ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameContactTextField.becomeFirstResponder()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        navigationController?.navigationBar.barTintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationController?.navigationBar.tintColor = UIColor.mainColor
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
        nameContactTextField.autocapitalizationType = .words
    }
    
    
    @IBAction func done() {
        guard let nameContact = nameContactTextField?.text, let address = addressTextField?.text else { return }
        guard let ethAddress = EthereumAddress(addressTextField?.text ?? "") else {
            showAlert(with: NSLocalizedString("Incorrect", comment: ""), message: NSLocalizedString("ValidAddr", comment: ""))
            return
        }
        service.saveContact(address: address, with: nameContact) { (error) in
            if error?.localizedDescription == "Address already exists in the database" {
                self.showAlert(with: NSLocalizedString("SameAddr", comment: ""), message: NSLocalizedString("AddrExist", comment: ""))
                return
            } else if error?.localizedDescription == "Name already exists in the database" {
                self.showAlert(with: NSLocalizedString("SameName", comment: ""), message: NSLocalizedString("NameExist", comment: ""))
                return
            } else if error != nil {
                return
            } else {
                if UIDevice.isIpad {
                    self.delegate?.didSave()
                    self.dismiss(animated: true, completion: nil )
                }else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
        
        
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




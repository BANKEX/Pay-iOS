//
//  EditViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 27.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol EditViewContollerDelegate:class {
    func didUpdateContact(name:String,address:String)
}

class EditViewController: BaseViewController {
    
    enum State {
        case enable,disable
    }
    
    @IBOutlet weak var nameTextField:UITextField!
    @IBOutlet weak var addrTextField:UITextField!
    @IBOutlet weak var saveButton:UIButton!
    
    weak var delegate:EditViewContollerDelegate?
    var selectedContact:FavoriteModel?
    var stateButton:State = .disable {
        didSet {
            if stateButton == .enable {
                saveButton.backgroundColor = WalletColors.mainColor
                saveButton.isEnabled = true
            }else {
                saveButton.backgroundColor = WalletColors.disableColor
                saveButton.isEnabled = false
            }
        }
    }
    let service = RecipientsAddressesServiceImplementation()
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTFs()
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(self.deleteContact)), animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = WalletColors.mainColor
        navigationController?.navigationBar.tintColor = .white
        UIApplication.shared.statusBarView?.backgroundColor = WalletColors.mainColor
        UIApplication.shared.statusBarStyle = .lightContent
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = .white
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = WalletColors.mainColor
    }
    
    private func prepareTFs() {
        [nameTextField,addrTextField].forEach {
            $0?.autocorrectionType = .no
            $0?.delegate = self
        }
        nameTextField.autocapitalizationType = .sentences
    }
    
    private func updateNameContact() {
        service.updateName(newName: nameTextField.text!, byAddress: selectedContact!.address)
    }
    private func updateAddressContact() {
        service.updateAddressByName(newAddress: addrTextField.text!, byName: selectedContact!.name)
    }
    
    private func updateUI() {
        if let selectedContact = selectedContact {
            nameTextField.text = selectedContact.name
            addrTextField.text = selectedContact.address
        }
    }
    
    @IBAction func pasteText() {
        if let pasteText = UIPasteboard.general.string {
            addrTextField.text = pasteText
            addrTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func saveContact() {
        updateNameContact()
        updateAddressContact()
        delegate?.didUpdateContact(name: nameTextField.text!, address: addrTextField.text!)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteContact() {
        let alertViewController = UIAlertController.destructive(button: "Delete") {
            self.service.delete(with: self.selectedContact!.address, completionHandler: {
                self.navigationController?.popToRootViewController(animated: true)
            })
        }
        present(alertViewController, animated: true)
    }
    

}

extension EditViewController:UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if !(nameTextField.text?.isEmpty ?? false) && !(addrTextField.text?.isEmpty ?? false) {
            stateButton = .enable
        }else {
            stateButton = .disable
        }
        return true
    }
}

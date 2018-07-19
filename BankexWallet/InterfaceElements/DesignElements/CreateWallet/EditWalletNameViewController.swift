//
//  EditWalletNameViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class EditWalletNameController: UIViewController {
    
    @IBOutlet weak var walletNameTextField: UITextField!
    weak var delegate: NameChangingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSetup()
    }
    
    @objc func saveButtonTapped() {
        guard let name = walletNameTextField.text, name != "" else { return }
        delegate?.nameChanged(to: name)
        self.navigationController?.popViewController(animated: true)
    }
    
    func navigationBarSetup() {
        navigationItem.title = "Wallet Name"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        let button = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = button
    }
    
}

protocol NameChangingDelegate: class {
    func nameChanged(to name: String)
}



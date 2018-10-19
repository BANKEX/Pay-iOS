//
//  EditWalletNameViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class EditWalletNameController: BaseViewController {
    
    @IBOutlet weak var walletNameTextField: UITextField!
    weak var delegate: NameChangingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        UIApplication.shared.statusBarStyle = .default
        UIApplication.shared.statusBarView?.backgroundColor = .white
    }
    
    @objc func saveButtonTapped() {
        guard let name = walletNameTextField.text, name != "" else { return }
        delegate?.nameChanged(to: name)
        self.navigationController?.popViewController(animated: true)
    }
    
    func navigationBarSetup() {
        navigationItem.title = NSLocalizedString("Wallet Name", comment: "")
        let saveBtn = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(saveButtonTapped))
        saveBtn.accessibilityLabel = "SaveBt"
        navigationItem.rightBarButtonItem = saveBtn
        let button = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = button
    }
    
}

protocol NameChangingDelegate: class {
    func nameChanged(to name: String)
}



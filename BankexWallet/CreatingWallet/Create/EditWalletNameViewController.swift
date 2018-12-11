//
//  EditWalletNameViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 17.07.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

class EditWalletNameController: BaseViewController {
    
    @IBOutlet weak var walletNameTextField: UITextField!
    weak var delegate: NameChangingDelegate?
    
    var isPopUpPresentation:Bool {
        return navigationItem.leftBarButtonItem?.customView != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        if isPopUpPresentation {
            UIApplication.shared.statusBarView?.backgroundColor = UIColor.greenColor
            UIApplication.shared.statusBarStyle = .lightContent
        }else {
            UIApplication.shared.statusBarView?.backgroundColor = .white
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    @objc func saveButtonTapped() {
        guard let name = walletNameTextField.text, name != "" else { return }
        delegate?.nameChanged(to: name)
        if isPopUpPresentation {
            dismiss(animated: true, completion: nil)
        }else {
           self.navigationController?.popViewController(animated: true)
        }
    }
    
    func navigationBarSetup() {
        navigationItem.title = NSLocalizedString("Wallet Name", comment: "")
        let saveBtn = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(saveButtonTapped))
        saveBtn.accessibilityLabel = "SaveBt"
        navigationItem.rightBarButtonItem = saveBtn
        let button = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = button
    }
    
    func addCancelButtonIfNeed() {
        let cancel = UIButton(type: .system)
        cancel.setTitle("Cancel", for: .normal)
        cancel.setTitleColor(UIColor.mainColor, for: .normal)
        cancel.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancel.addTarget(self, action: #selector(fadeOut), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancel)
    }
    
    @objc func fadeOut() {
        dismiss(animated: true, completion: nil)
    }
    
}

protocol NameChangingDelegate: class {
    func nameChanged(to name: String)
}



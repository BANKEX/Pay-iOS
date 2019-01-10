//
//  RenameViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 01.10.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol RenameViewControllerDelegate:class {
    func didUpdateWalletName(name:String)
    func addressOfWallet() -> String
}

class RenameViewController: BaseViewController {
    
    @IBOutlet weak var nameWalletTF:UITextField!
    @IBOutlet var saveBarButtonItem: UIBarButtonItem!
    
    var selectedWalletName:String!
    let service = HDWalletServiceImplementation()
    weak var delegate:RenameViewControllerDelegate?
    var isSimilarName:Bool {
        if let initialName = selectedWalletName, let enteredName = nameWalletTF.text {
            return initialName == enteredName
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = LocalizedStrings.title
        saveBarButtonItem.title = LocalizedStrings.save
    }
    
    func addCancelButtonIfNeed() {
        let cancel = UIButton(type: .system)
        cancel.setTitle(LocalizedStrings.cancel, for: .normal)
        cancel.setTitleColor(UIColor.mainColor, for: .normal)
        cancel.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancel.addTarget(self, action: #selector(fadeOut), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancel)
    }
    
    @objc func fadeOut() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveWalletName() {
        if isSimilarName {
            if UIDevice.isIpad {
                dismiss(animated: true, completion: nil)
            }else {
                navigationController?.popViewController(animated: true)
            }
            return
        }
        if let nameWallet = nameWalletTF.text {
            service.updateWalletName(name: nameWallet, address: delegate!.addressOfWallet()) { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.delegate?.didUpdateWalletName(name: nameWallet)
                if UIDevice.isIpad {
                    self.dismiss(animated: true, completion: nil)
                }else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.isIpad {
            UIApplication.shared.statusBarView?.backgroundColor = nil
        }
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameWalletTF.becomeFirstResponder()
    }
    
    func updateUI() {
        nameWalletTF.text = selectedWalletName
    }

}


private extension RenameViewController {
    
    struct LocalizedStrings {
        static let title = NSLocalizedString("Title", tableName: "WalletRename", comment: "")
        static let save = NSLocalizedString("SaveBarButtonTitle", tableName: "WalletRename", comment: "")
        static let cancel = NSLocalizedString("CancelBarButtonTitle", tableName: "WalletRename", comment: "")
    }
    
}

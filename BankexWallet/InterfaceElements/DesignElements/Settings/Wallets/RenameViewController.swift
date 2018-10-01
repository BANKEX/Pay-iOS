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
        let rightBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.saveWalletName))
        navigationItem.setRightBarButton(rightBarButton, animated: false)
    }
    
    @IBAction func saveWalletName() {
        if isSimilarName {
            navigationController?.popViewController(animated: true)
            return
        }
        if let nameWallet = nameWalletTF.text {
            service.updateWalletName(name: nameWallet, address: delegate!.addressOfWallet()) { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.delegate?.didUpdateWalletName(name: nameWallet)
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

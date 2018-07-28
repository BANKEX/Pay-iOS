//
//  ProfileContactViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 28.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ProfileContactViewController: UITableViewController,UITextFieldDelegate {
    
    @IBOutlet weak var addressTextField:UITextField?
    @IBOutlet weak var noteTextView:UITextView?
    
    
    enum State {
        case Editable,notEditable
    }
    
    
    
    var selectedContact:FavoriteModel!
    var state:State = .notEditable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        configureTableView()
        configureNavBar()
    }
    
    func configureNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(switchEditState))
    }
    
    func configureTableView() {
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    func configureTextField() {
        addressTextField?.borderStyle = .none
        addressTextField?.delegate = self
        addressTextField?.textColor = WalletColors.blueText.color()
        addressTextField?.autocorrectionType = .no
        addressTextField?.autocapitalizationType = .none
    }
    
    func updateUI() {
        addressTextField?.text = selectedContact.address
    }
    
    
    @objc func switchEditState() {
        state = (state == .Editable) ? .notEditable : .Editable
    }
    
    @IBAction func sendFunds() {
        //TODO
    }
    
    @IBAction func shareContact() {
        //TODO
    }
    
    @IBAction func removeContact() {
        //TODO
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return state == .Editable ? true : false
    }

}

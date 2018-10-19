//
//  CreateNetworkViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 23.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class CreateNetworkViewController: UITableViewController,UITextFieldDelegate {
    
    
    enum State {
        case available,unavailable
    }
    
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var networkURLTextField:UITextField!
    @IBOutlet weak var networkNameTextField:UITextField!
    @IBOutlet weak var networkIDTextField:UITextField!
    @IBOutlet var textFields:[UITextField]!
    
    
    var joinButton = UIBarButtonItem(title: NSLocalizedString("Join", comment: ""), style: .done, target: self, action: #selector(joinToConnection))
    var state:State = .unavailable {
        didSet {
            if state == .available {
                joinButton.isEnabled = true
                [networkNameTextField,networkURLTextField,networkIDTextField].forEach { tf in
                    tf?.returnKeyType = .done
                }
            }else {
                joinButton.isEnabled = false
                [networkNameTextField,networkURLTextField,networkIDTextField].forEach { tf in
                    tf?.returnKeyType = .next
                }
            }
        }
    }
    
    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        state = .unavailable
        commonSetup()
    }
    
    fileprivate func commonSetup() {
        [networkNameTextField,networkURLTextField,networkIDTextField].forEach { (tf) in
            tf?.delegate = self
            tf?.autocorrectionType = .no
        }
        prepareNavbar()
        tableView.separatorStyle = .none
        networkURLTextField.becomeFirstResponder()
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resignTextFields)))
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.bgMainColor
    }
    

    fileprivate func prepareNavbar() {
        navigationItem.title = NSLocalizedString("NewNetwork", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(back))
        navigationItem.rightBarButtonItem = joinButton
    }
    
    //MARK: - Methods
    @objc func textFromBuffer() {
        if let text = UIPasteboard.general.string {
            networkURLTextField.text = text
            guard networkNameTextField.text != "" && networkURLTextField.text != "" && networkIDTextField.text != "" else { return }
            state = .available
        }
    }
    
    @objc func resignTextFields() {
        for tf in [networkURLTextField,networkNameTextField,networkIDTextField] {
            tf?.resignFirstResponder()
        }
    }
    
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func joinToConnection(_ sender:Any) {
        //TODO
    }

    //MARK: - DataSource
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView()
            view.backgroundColor = UIColor.bgMainColor
            view.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.sectionHeaderHeight)
            let pasteButton = PasteButton()
            pasteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
            pasteButton.frame = CGRect(x: 16.0, y: 5, width: 66.0, height: 35.0)
            pasteButton.backgroundColor = UIColor.bgMainColor
            view.addSubview(pasteButton)
            return view
        }else {
            let v = UIView()
            v.backgroundColor = UIColor.bgMainColor
            return v
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done && joinButton.isEnabled {
            joinToConnection(self)
        }else if textField.returnKeyType == .next {
            var nextIndex:Int
            guard textFields.contains(textField) else { return false }
            var currentIndex:Int = textFields.index(of: textField) ?? 0
            if textField == networkIDTextField {
                nextIndex = 0
            }else {
                nextIndex = currentIndex + 1
            }
            textFields[nextIndex].becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if networkNameTextField.text == "" || networkURLTextField.text == "" || networkIDTextField.text == "" {
            state = .unavailable
        }else {
            state = .available
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "")  as NSString
        let futureString = currentText.replacingCharacters(in: range, with: string) as String
        if (textField == networkNameTextField && !futureString.isEmpty && !(networkURLTextField.text?.isEmpty)! && !(networkIDTextField.text?.isEmpty)!) || (textField == networkURLTextField && !futureString.isEmpty && !(networkNameTextField.text?.isEmpty)! && !(networkIDTextField.text?.isEmpty)!) || (textField == networkIDTextField && !futureString.isEmpty && !(networkNameTextField.text?.isEmpty)! && !(networkURLTextField.text?.isEmpty)!) {
            state = .available
        }else {
            state = .unavailable
        }
        return true
    }
    
    
}

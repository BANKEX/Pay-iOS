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

class AddContactViewController: UITableViewController,UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTextField:UITextField!
    @IBOutlet weak var lastNameTextField:UITextField!
    @IBOutlet weak var addressTextField:UITextField!
    
    
    
    enum State {
        case noAvailable,available
    }
    
    
    var state:State = State.noAvailable {
        didSet {
            if state == .noAvailable {
                doneButton.isEnabled = false
            }else {
                doneButton.isEnabled = true
            }
        }
    }
    var headerView:UIView!
    let heightOfRow:CGFloat = 47.0
    var doneButton:UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
    var service = RecipientsAddressesServiceImplementation()
    let radius:CGFloat = 43.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField?.becomeFirstResponder()
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeBecomeResponser)))
        setupTextFields()
        setupNavBar()
        setupHeader()
        setupFooter()

        
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        state = .noAvailable
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Title"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(back))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func setupTextFields() {
        [addressTextField,firstNameTextField,lastNameTextField].forEach { tf in
            tf?.delegate = self
            tf?.autocorrectionType = .no
        }
        firstNameTextField.autocapitalizationType = .words
        lastNameTextField.autocapitalizationType = .words
    }
    
    func setupFooter() {
        var heightOfFooter:CGFloat!
        if #available(iOS 11.0, *) {
            heightOfFooter = UIScreen.main.bounds.height - (heightOfRow * 3) - headerView.bounds.height - (navigationController?.navigationBar.bounds.height)! + 30
        }else {
            heightOfFooter = UIScreen.main.bounds.height - (heightOfRow * 3) - headerView.bounds.height - (navigationController?.navigationBar.bounds.height)!
        }
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: heightOfFooter))
        let pasteButton = UIButton(frame: CGRect(x: 16, y: 15, width: 140.0, height: 28.0))
        pasteButton.setImage(#imageLiteral(resourceName: "Paste button"), for: .normal)
        pasteButton.addTarget(self, action: #selector(importFromBuffer(_:)), for: .touchUpInside)
        footerView.addSubview(pasteButton)
        footerView.backgroundColor = .white
        tableView.tableFooterView = footerView
    }
    
    func setupHeader() {
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 160.0))
        tableView.tableHeaderView = headerView
        createCircle()
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func done() {
        guard let firstName = firstNameTextField?.text,let lastName = lastNameTextField?.text,let address = addressTextField?.text else { return }
        guard let ethAddress = EthereumAddress(addressTextField?.text ?? "") else {
            showAlert(with: "Incorrect address", message: "Please enter valid address")
            return
        }
        service.store(address: address, with: firstName,lastName: lastName , isEditing: false) { (error) in
            if error?.localizedDescription == "Address already exists in the database" {
                self.showAlert(with: "Same Address", message: "Address already exists in your contacts")
                return
            } else if error?.localizedDescription == "Name already exists in the database" {
                self.showAlert(with: "Same Name", message: "Name already exists in your contacts")
                return
            } else if error != nil {
                return
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }
        
        
    }
    
    @objc func removeBecomeResponser() {
        [addressTextField,firstNameTextField,lastNameTextField].forEach { tf in
            tf?.resignFirstResponder()
        }
    }
    
    fileprivate func createCircle() {
        guard let header = headerView else { return }
        let circlePath = UIBezierPath(arcCenter: CGPoint(x:header.bounds.midX, y: header.bounds.midY), radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        let shapelayer = CAShapeLayer()
        shapelayer.path = circlePath.cgPath
        shapelayer.fillColor = UIColor.white.cgColor
        shapelayer.lineWidth = 0.8
        shapelayer.strokeColor = UIColor.lightGray.cgColor
        let heightPhotoLabe:CGFloat = 15.0
        let label = UILabel()
        label.text = "add photo"
        label.textColor = WalletColors.blueText.color()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.sizeToFit()
        label.frame.origin = CGPoint(x:(shapelayer.path?.boundingBox.minX)! + shapelayer.lineWidth, y: header.bounds.midY - label.bounds.height/2)
        label.frame.size = CGSize(width: (shapelayer.path?.boundingBox.width)! - 2, height: heightPhotoLabe)
        
        
        
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: radius*2, height: radius*2)
        button.backgroundColor = UIColor.clear
        button.frame.origin = CGPoint(x: (shapelayer.path?.boundingBox.minX)!, y: (shapelayer.path?.boundingBox.minY)!)
        button.layer.cornerRadius = radius
        button.addTarget(self, action: #selector(callImagePicker), for: .touchUpInside)

        headerView.layer.addSublayer(shapelayer)
        headerView.addSubview(label)
        headerView.addSubview(button)
        
        
        
    }
    
    @objc func callImagePicker( ) {
        //TODO
    }
    
    
    
    @objc func importFromBuffer(_ sender:Any) {
        if let text = UIPasteboard.general.string {
            addressTextField?.text = text
            if !(firstNameTextField?.text?.isEmpty ?? true) && !(lastNameTextField?.text?.isEmpty ?? true) {
                state = .available
            }else {
                state = .noAvailable
            }
        }
        
    }
    
    func showAlert(with title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightOfRow
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = (textField.text ?? "") as NSString
        let futureString = currentString.replacingCharacters(in: range, with: string) as String
        switch textField {
        case firstNameTextField:
            if !futureString.isEmpty && !(lastNameTextField?.text?.isEmpty ?? true) && !(addressTextField?.text?.isEmpty ?? true) {
                state = .available
            }else {
                state = .noAvailable
            }
        case lastNameTextField:
            if !futureString.isEmpty && !(firstNameTextField?.text?.isEmpty ?? true) && !(addressTextField?.text?.isEmpty ?? true) {
                state = .available
            }else {
                state = .noAvailable
            }
        case addressTextField:
            if !futureString.isEmpty && !(firstNameTextField?.text?.isEmpty ?? true) && !(lastNameTextField?.text?.isEmpty ?? true) {
                state = .available
            }else {
                state = .noAvailable
            }
        default:
            state = .noAvailable
        }
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




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
    @IBOutlet var textFields:[UITextField]!
    @IBOutlet weak var pasteButton:UIButton!
    
    
    
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
    var radius:CGFloat = 43.0
    var circleView:UIView = {
       var view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 43.0
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 0.75
        return view
    }()
    lazy var wordLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 48.0)
        label.numberOfLines = 1
        label.sizeToFit()
        label.textAlignment = .center
        label.textColor = UIColor.black
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField?.becomeFirstResponder()
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeBecomeResponser)))
        setupTextFields()
        setupNavBar()
        setupHeader()        
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        state = .noAvailable
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clearInfo()
        state = .noAvailable
        self.removeFromParentViewController()
    }
    
    func clearInfo() {
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        addressTextField.text = ""
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "New Contact"
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
    
    func setupHeader() {
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 160.0))
        createCircle()
        addWordLabel()
        tableView.tableHeaderView = headerView
    }
    
    func addWordLabel() {
        wordLabel.frame.origin = CGPoint(x: 19.0, y: 15.0)
        wordLabel.frame.size = CGSize(width: 48.0, height: 57.0)
        circleView.addSubview(wordLabel)
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
        let circleX = headerView.bounds.midX - radius - 0.75
        circleView.frame.origin = CGPoint(x:circleX, y:22.0)
        circleView.frame.size = CGSize(width: radius*2, height: radius*2)
        headerView.addSubview(circleView)
    }
    
    
    
    
    @IBAction func importFromBuffer(_ sender:Any) {
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
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            if let heightOfNavBar = navigationController?.navigationBar.frame.height {
                let heightStatusbar = UIApplication.shared.statusBarFrame.height //Default 20.0
                let restRect = heightOfRow * 3 + headerView.bounds.height + heightOfNavBar + heightStatusbar
                return UIScreen.main.bounds.height - restRect
            }
        }
        return heightOfRow
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = state == .available ? .done : .next
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
            wordLabel.text = futureString.prefix(1).uppercased()
        case addressTextField:
            if !futureString.isEmpty && !(firstNameTextField?.text?.isEmpty ?? true) && !(lastNameTextField?.text?.isEmpty ?? true) {
                state = .available
            }else {
                state = .noAvailable
            }
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




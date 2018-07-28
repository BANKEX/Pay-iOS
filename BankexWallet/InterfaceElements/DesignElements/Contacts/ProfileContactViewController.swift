//
//  ProfileContactViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 28.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ProfileContactViewController: UITableViewController,UITextFieldDelegate,UITextViewDelegate {
    
    @IBOutlet weak var addressTextField:UITextField?
    @IBOutlet weak var noteTextView:UITextView!
    
    
    enum State {
        case Editable,notEditable
    }
    
    let service = RecipientsAddressesServiceImplementation()
    var selectedNote:String!
    var selectedContact:FavoriteModel!
    var state:State = .notEditable {
        didSet{
            if state == .notEditable {
                unselectKeyboard()
                navigationItem.rightBarButtonItem?.title = "Edit"
            }else {
                addressTextField?.becomeFirstResponder()
                navigationItem.rightBarButtonItem?.title = "Cancel"
            }
        }
    }
    let heightHeader:CGFloat = 160.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        configureTableView()
        configureNavBar()
        configureTextView()
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unselectKeyboard)))
    }
    
    @objc func unselectKeyboard() {
        addressTextField?.resignFirstResponder()
        noteTextView.resignFirstResponder()
    }
    
    func configureTextView() {
        noteTextView?.delegate = self
        noteTextView.font = UIFont.systemFont(ofSize: 15.0)
    }
    
    func configureNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(switchEditState))
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = UIColor(red: 251/255, green: 250/255, blue: 255/255, alpha: 1)
    }
    
    func configureTableView() {
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView(frame: .zero)
        createHeaderView()
    }
    
    func createHeaderView() {
        let headerView = UIView()
        headerView.frame.size = CGSize(width: tableView.bounds.width, height: heightHeader)
        headerView.backgroundColor = UIColor(red: 251/255, green: 250/255, blue: 255/255, alpha: 1)
        headerView.layer.masksToBounds = false
        headerView.layer.shadowColor = UIColor(red: 188/255, green: 187/255, blue: 193/255, alpha: 1).cgColor
        headerView.layer.shadowOffset = CGSize(width: 0.0, height: 0.6)
        headerView.layer.shadowOpacity = 1.0
        headerView.layer.shadowRadius = 0.0
        tableView.tableHeaderView = headerView
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
        if selectedNote == nil {
            noteTextView.applyPlaceHolderText(with: "Notes")
        }else {
            noteTextView.text = selectedNote
        }
    }
    
    
    @objc func switchEditState() {
        state = (state == .Editable) ? .notEditable : .Editable
    }
    
    @IBAction func sendFunds() {
        //TODO
    }
    
    @IBAction func shareContact() {
        let firstActivityItem = "Text"
        let activityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivityType.postToTencentWeibo,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo
        ]
        
        present(activityViewController, animated: true)
    }
    
    @IBAction func removeContact() {
        guard let address = addressTextField?.text,service.contains(address: address) else { return }
        service.delete(with: address) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return state == .Editable ? true : false
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView == noteTextView else { return  }
        guard textView.text == "Notes" else { return  }
        noteTextView.moveCursorToStart()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 {
            if textView == noteTextView && textView.text == "Notes" {
                if text.utf16.count == 0 {
                    return false
                }
                textView.applyNotHolder()
            }
            return true
        }else {
            textView.applyPlaceHolderText(with: "Notes")
            noteTextView.moveCursorToStart()
            return false
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return state == .Editable ? true : false
    }
    
    

}

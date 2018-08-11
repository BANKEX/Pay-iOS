//
//  ProfileContactViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 28.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ProfileContactViewController: UITableViewController,UITextFieldDelegate,UITextViewDelegate {
    
    @IBOutlet weak var addressTextField:UITextField!
    @IBOutlet weak var noteTextView:UITextView!
    
    //MARK: - Properties
    enum State {
        case Editable,notEditable
    }
    
    
    lazy var nameContactLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.sizeToFit()
        label.textAlignment = .center
        return label
    }()
    lazy var circleView:UIView = {
        let circle = UIView()
        circle.backgroundColor = UIColor.white
        circle.layer.cornerRadius = 86.0/2.0
        circle.layer.borderColor = UIColor.black.cgColor
        circle.layer.borderWidth = 0.75
        return circle
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
    lazy var activityViewController:UIActivityViewController = {
        let activityViewController = UIActivityViewController(activityItems: [], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivityType.postToTencentWeibo,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo
        ]
        return activityViewController
    }()
    lazy var alertViewController:UIAlertController = {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let delButton = UIAlertAction(title:"Delete", style: .destructive) { _ in
            guard let address = self.addressTextField?.text, self.service.contains(address: address) else { return }
            self.service.delete(with: address) {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertVC.addAction(delButton)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default))
        return alertVC
    }()
    let service = RecipientsAddressesServiceImplementation()
    var selectedNote:String!
    var selectedContact:FavoriteModel!
    let heightNameLabel:CGFloat = 36.0
    let heightHeader:CGFloat = 160.0
    let heightCircle:CGFloat = 86.0
    let placeholderString = "Notes"
    var state:State = .notEditable {
        didSet{
            if state == .notEditable {
                unselectKeyboard()
                navigationItem.rightBarButtonItem?.title = "Edit"
                navigationItem.hidesBackButton = false
                navigationItem.setHidesBackButton(false, animated: true)
            }else {
                addressTextField?.becomeFirstResponder()
                navigationItem.rightBarButtonItem?.title = "Save"
                navigationItem.setHidesBackButton(true, animated: true)
            }
        }
    }
    
    
    
    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        configureTableView()
        configureNavBar()
        configureTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = WalletColors.headerView.color()
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.shadowImage = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let address = addressTextField?.text,service.contains(address: address) else { return }
        if let controller = segue.destination as? SendTokenViewController {
            controller.selectedFavoriteAddress = address
        }
    }
    
    
    
    //MARK: - Methods
    @objc func unselectKeyboard() {
        addressTextField?.resignFirstResponder()
        noteTextView.resignFirstResponder()
    }
    
    func configureTextView() {
        noteTextView?.delegate = self
        noteTextView.font = UIFont.systemFont(ofSize: 15.0)
        noteTextView.autocorrectionType = .no
    }
    
    func configureNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(switchEditState))
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = WalletColors.headerView.color()
    }
    
    func configureTableView() {
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unselectKeyboard)))
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView(frame: .zero)
        createHeaderView()
    }
    
    func createHeaderView() {
        let headerView = UIView()
        headerView.frame.size = CGSize(width: tableView.bounds.width, height: heightHeader)
        headerView.backgroundColor = WalletColors.headerView.color()
        headerView.bottomBorder()
        nameContactLabel.frame.size = CGSize(width: tableView.bounds.width, height: heightNameLabel)
        nameContactLabel.frame.origin = CGPoint(x: 0, y: headerView.bounds.maxY - 28.0 - heightNameLabel)
        circleView.frame.size = CGSize(width: heightCircle, height: heightCircle)
        circleView.frame.origin = CGPoint(x: headerView.bounds.width/2 - (heightCircle/2) - 0.75, y: 0.75 * 2)
        wordLabel.frame.origin = CGPoint(x: 19.0, y: 15.0)
        wordLabel.frame.size = CGSize(width: 48.0, height: 57.0)
        circleView.addSubview(wordLabel)
        headerView.addSubview(circleView)
        headerView.addSubview(nameContactLabel)
        tableView.tableHeaderView = headerView
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
        if let note = selectedContact.note {
            noteTextView.text = note
        }else {
            noteTextView.applyPlaceHolderText(with: placeholderString)
        }
        nameContactLabel.attributedText = prepareText()
        //If contact not have image
        wordLabel.text = String(selectedContact.lastname.prefix(1)).uppercased()
    }
    
    func prepareText() -> NSAttributedString {
        let firstString = selectedContact.firstName
        let lastString = selectedContact.lastname
        let firstAttr = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 30.0)]
        let attrFirstString = NSAttributedString(string: firstString, attributes: firstAttr)
        let secondAttr = [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 30.0)]
        let attrSecondString = NSAttributedString(string: lastString, attributes: secondAttr)
        var attrString = NSMutableAttributedString(attributedString: attrFirstString)
        attrString.append(NSAttributedString(string: " "))
        attrString.append(attrSecondString)
        return attrString
    }
    
    
    @objc func switchEditState() {
        state = (state == .Editable) ? .notEditable : .Editable
    }
    
    
    //MARK: - IBAction
    
    @IBAction func sendFunds() {
        performSegue(withIdentifier: "showSendSegue", sender: self)
    }
    
    
    @IBAction func shareContact() {
        if let popOver = activityViewController.popoverPresentationController {
            popOver.sourceView = tableView
            popOver.sourceRect = CGRect(x: tableView.bounds.midX, y: tableView.bounds.maxY, width: 0, height: 0)
            popOver.permittedArrowDirections = []
            present(activityViewController, animated: true)
            return
        }
        present(activityViewController, animated: true)
    }
    
    
    @IBAction func removeContact() {
        if let popOver = alertViewController.popoverPresentationController {
            popOver.sourceView = tableView
            popOver.sourceRect = CGRect(x: tableView.bounds.midX, y: tableView.bounds.maxY, width: 0, height: 0)
            popOver.permittedArrowDirections = []
            present(alertViewController, animated: true)
            return
        }
        present(alertViewController, animated: true)
    }
    
    //MARK: - TextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return state == .Editable ? true : false
    }
    
    
    
    //MARK: - TextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView == noteTextView else { return  }
        guard textView.text == placeholderString else { return  }
        noteTextView.moveCursorToStart()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 {
            if textView == noteTextView && textView.text == placeholderString {
                if text.utf16.count == 0 {
                    return false
                }
                textView.applyNotHolder()
            }
            return true
        }else {
            textView.applyPlaceHolderText(with: placeholderString)
            noteTextView.moveCursorToStart()
            return false
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return state == .Editable ? true : false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard !textView.text.isEmpty else { return }
        if let address = addressTextField?.text {
            if !textView.isPlaceholder {
                service.updateNote(note: textView.text, byAddress: address)
            }else {
                service.updateNote(note: nil, byAddress: address)
            }
            
        }
    }
    
    

}

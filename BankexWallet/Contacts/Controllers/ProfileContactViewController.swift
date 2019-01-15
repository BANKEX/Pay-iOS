//
//  ProfileContactViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 28.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreSpotlight
import SkeletonView

struct Mediator {
     public static var contactAddr:String?
}

struct HistoryMediator {
    
    enum TabItem: Int {
        case wallet = 0, history, contacts, settings
    }

    public static var addr:String?
    
    public static func handleDidSelect(item: Int) {
        if item == TabItem.history.rawValue {
            addr = nil
        }
    }
}


class ProfileContactViewController: BaseViewController,UITextFieldDelegate,UITextViewDelegate {
    
    enum State {
        case loading,empty,fill
    }
    

    @IBOutlet weak var nameContactLabel:UILabel!
    @IBOutlet weak var addrContactLabel:UILabel!
    @IBOutlet weak var infoView:UIView!
    @IBOutlet weak var tableVIew:UITableView!
    @IBOutlet weak var seeAllBtn:UIButton!
    @IBOutlet weak var heightConstraint:NSLayoutConstraint!

    //MARK: - Properties

    lazy var alertViewController:UIAlertController = {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let delButton = UIAlertAction(title:NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
            guard let address = self.addrContactLabel?.text, self.service.contains(address: address) else { return }
            self.service.delete(with: address) { _ in
                self.searchManager.deindex()
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertVC.addAction(delButton)
        alertVC.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default))
        return alertVC
    }()
    var state:State = .loading {
        didSet {
            switch state {
            case .loading:
                tableVIew.isHidden = true
                seeAllBtn.isHidden = true
            case .empty:
                tableVIew.isHidden = false
                seeAllBtn.isHidden = true
            case .fill:
                tableVIew.isHidden = false
                seeAllBtn.isHidden = false
            }
        }
    }
    var transactions:[ETHTransactionModel] = []
    let service = ContactService()
    var selectedContact:FavoriteModel!
    var searchManager:SearchManager!
    var sendService = SendEthServiceImplementation()
    var clipboardView:ClipboardView!


    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupClipboardView()
        commonPrepare()
        configureTableView()
        prepareUserActivity()
    }
    
    func setupClipboardView() {
        clipboardView = ClipboardView(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 58))
        clipboardView.title = "Address copied to clipboard"
        clipboardView.color = UIColor.clipboardColor
        view.addSubview(clipboardView)
    }
  

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HistoryMediator.addr = selectedContact.address.lowercased()
        manageTop()
        updateUI()
        state = .loading
        updateTransactions()
    }
    
    func updateTransactions() {
        TransactionsService().refreshTransactionsInSelectedNetwork(type: .ETH, forAddress: selectedContact!.address, node: nil) { isGood in
            if isGood {
                self.transactions = Array(self.sendService.getAllTransactions(addr:nil).prefix(3).filter({ tr -> Bool in
                    if tr.to == self.selectedContact.address.lowercased() {
                        return true
                    }
                    return false
                }))
                self.state = self.transactions.isEmpty ? .empty : .fill
                self.tableVIew.reloadData()
            }else {
                print("Appear error")
            }
        }
    }
    
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        manageTop(isHide: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? HomeViewController {
            guard let address = selectedContact?.address,service.contains(address: address) else { return }
            Mediator.contactAddr = address
            controller.isFromContact = true
        }else if let editVC = segue.destination as? EditViewController {
            editVC.selectedContact = selectedContact
            editVC.delegate = self
        }
    }
    
    @IBAction func editContact() {
        if UIDevice.isIpad {
            let editContact = CreateVC(byName: "EditViewController") as! EditViewController
            editContact.addCancelButtonIfNeed()
            editContact.delegate = self
            editContact.selectedContact = selectedContact
            presentPopUp(editContact, size: CGSize(width: splitViewController!.view.bounds.width/2, height: splitViewController!.view.bounds.height/2))
        }else {
            self.performSegue(withIdentifier: "editSegue", sender: nil)
        }
    }



    @IBAction func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func commonPrepare() {
        title = NSLocalizedString("Contacts", comment: "")
        infoView.backgroundColor = UIColor.mainColor
    }
    
    private func manageTop(isHide:Bool = true) {
        if isHide {
            navigationController?.setNavigationBarHidden(isHide, animated: false)
            navigationController?.navigationBar.barTintColor = UIColor.mainColor
            navigationController?.navigationBar.tintColor = .white
            UIApplication.shared.statusBarView?.backgroundColor = UIDevice.isIpad ? .white : UIColor.mainColor
            UIApplication.shared.statusBarStyle = UIDevice.isIpad ? .default : .lightContent
            return
        }
        navigationController?.isNavigationBarHidden = isHide
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = UIColor.mainColor
        UIApplication.shared.statusBarStyle = .default
    }
    
    @IBAction func seeAll() {
        let historyVC = CreateVC(byName: "TransactionHistoryViewController") as! TransactionHistoryViewController
        navigationController?.pushViewController(historyVC, animated: true)
    }

    private func configureTableView() {
        tableVIew.delegate = self
        tableVIew.dataSource = self
        tableVIew.register(UINib(nibName: TransactionInfoCell.identifer, bundle: nil), forCellReuseIdentifier: TransactionInfoCell.identifer)
        tableVIew.register(UINib(nibName: EmptyTableCell.identifier, bundle: nil), forCellReuseIdentifier: EmptyTableCell.identifier)
        tableVIew.register(UINib(nibName: DeleteCell.identifier, bundle: nil), forCellReuseIdentifier: DeleteCell.identifier)
        tableVIew.backgroundColor = UIColor.bgMainColor
        tableVIew.isScrollEnabled = true
        heightConstraint.setMultiplier(multiplier: UIDevice.isIpad ? 1/4.76 : 1/3.3)
        if #available(iOS 11.0, *) {
            tableVIew.separatorInsetReference = .fromCellEdges
        } else {
        }
        tableVIew.separatorInset.left = 48
        tableVIew.tableFooterView = UIDevice.isIpad ? UIView() : footerTableView
    }
    
    
    private func prepareUserActivity() {
        searchManager = SearchManager(contact: selectedContact)
        let activity = selectedContact.userActivity
        activity.isEligibleForSearch = true
        self.userActivity = activity
        searchManager.index()
    }



     private func updateUI() {
        guard let selectedContact = selectedContact else { return }
        nameContactLabel.text = selectedContact.name
        addrContactLabel.text = selectedContact.address.formattedAddrToken(number: 5)
    }
    
    
    func removeContact() {
        let alertViewController = UIAlertController(title: "Delete contact?", message: nil, preferredStyle: .alert)
        alertViewController.addCancel()
        alertViewController.addDestructive(title: NSLocalizedString("Delete", comment: "")) {
            self.service.delete(with: self.selectedContact.address, completionHandler: { isSuccess in
                if isSuccess {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        alertViewController.addPopover(in: view, rect: CGRect(x: 0, y: 0, width: 270, height: 105))
        present(alertViewController, animated: true)
    }

    //MARK: - IBAction
    
    @IBAction func sendFunds() {
        if UIDevice.isIpad {
            selectSection(0)
        }
        self.performSegue(withIdentifier: "isFromContact", sender: nil)
    }


    @IBAction func shareContact() {
        let text = "\(selectedContact!.address)"
        let activity = UIActivityViewController.activity(content: text)
        activity.completionWithItemsHandler = { (type, isSuccess, items, error) in
            if isSuccess && error == nil {
                self.clipboardView.showClipboard()
            }
        }
        if UIDevice.isIpad {
            activity.addPopover(in: view, rect: CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0))
        }
        present(activity, animated: true)
    }
}

extension ProfileContactViewController:EditViewContollerDelegate {
    func didUpdateContact(name: String, address: String) {
        service.contactByAddress(address) { contact in
            self.selectedContact = contact
            self.updateUI()
        }
    }
}

extension ProfileContactViewController:DeleteCellDelegate {
    func didTapRemoveButton() {
        removeContact()
    }
}


extension ProfileContactViewController:UITableViewDataSource,UITableViewDelegate,SkeletonTableViewDataSource {
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return TransactionInfoCell.identifer
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UIDevice.isIpad && transactions.isEmpty {
            return 2
        }else if !UIDevice.isIpad && transactions.isEmpty {
            return 1
        }else if !transactions.isEmpty && UIDevice.isIpad {
            return transactions.count + 1
        }else {
            return transactions.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if transactions.isEmpty && indexPath.row == 0 {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: EmptyTableCell.identifier, for: indexPath) as! EmptyTableCell
            emptyCell.setData("You don't have any transaction history yet")
            return emptyCell
        }else if transactions.isEmpty && UIDevice.isIpad && indexPath.row == 1 {
            let delCell = tableView.dequeueReusableCell(withIdentifier: DeleteCell.identifier, for: indexPath) as! DeleteCell
            delCell.delegate = self
            return delCell
        }else if indexPath.row == transactions.count {
            let delCell = tableView.dequeueReusableCell(withIdentifier: DeleteCell.identifier, for: indexPath) as! DeleteCell
            delCell.delegate = self
            return delCell
        }
        let cell = tableVIew.dequeueReusableCell(withIdentifier: TransactionInfoCell.identifer, for: indexPath) as! TransactionInfoCell
        cell.transaction = transactions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if transactions.isEmpty && UIDevice.isIpad && indexPath.row == 0 {
            return 240
        }else if transactions.isEmpty && !UIDevice.isIpad {
            return tableVIew.bounds.height
        }else if (transactions.isEmpty && UIDevice.isIpad && indexPath.row == 1) || transactions.count == indexPath.row {
            return 44
        }else if !transactions.isEmpty && UIDevice.isIpad && indexPath.row == transactions.count - 1 {
            return 71
        }else {
            return 53
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UIDevice.isIpad && indexPath.row == transactions.count {
            removeContact()
        }else if UIDevice.isIpad && transactions.isEmpty && indexPath.row == 1 {
            removeContact()
        }
    }
}




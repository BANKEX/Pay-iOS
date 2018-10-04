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
    public static var addr:String?
}


class ProfileContactViewController: BaseViewController,UITextFieldDelegate,UITextViewDelegate {

    @IBOutlet weak var nameContactLabel:UILabel!
    @IBOutlet weak var addrContactLabel:UILabel!
    @IBOutlet weak var infoView:UIView!
    @IBOutlet weak var tableVIew:UITableView!

    //MARK: - Properties

    lazy var alertViewController:UIAlertController = {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let delButton = UIAlertAction(title:NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
            guard let address = self.addrContactLabel?.text, self.service.contains(address: address) else { return }
            self.service.delete(with: address) {
                self.searchManager.deindex()
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        alertVC.addAction(delButton)
        alertVC.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default))
        return alertVC
    }()
    var transactions:[ETHTransactionModel] = []
    let service = RecipientsAddressesServiceImplementation()
    var selectedContact:FavoriteModel!
    var searchManager:SearchManager!
    var sendService = SendEthServiceImplementation()



    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        commonPrepare()
        configureTableView()
        prepareUserActivity()
    }
  

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manageTop()
        updateUI()
        view.showSkeleton()
        TransactionsService().refreshTransactionsInSelectedNetwork(forAddress: selectedContact!.address) { isGood in
            if isGood {
                self.transactions = Array(self.sendService.getAllTransactions(addr:nil).prefix(3).filter({ tr -> Bool in
                    if tr.to == self.selectedContact.address.lowercased() {
                        return true
                    }
                    return false
                }))
                self.tableVIew.reloadData()
                self.view.stopSkeletonAnimation()
                self.view.hideSkeleton()
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
        self.performSegue(withIdentifier: "editSegue", sender: nil)
    }



    @IBAction func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func commonPrepare() {
        title = "Contacts"
        infoView.backgroundColor = WalletColors.mainColor
    }
    
    private func manageTop(isHide:Bool = true) {
        if isHide {
            navigationController?.setNavigationBarHidden(isHide, animated: true)
            navigationController?.navigationBar.barTintColor = WalletColors.mainColor
            navigationController?.navigationBar.tintColor = .white
            UIApplication.shared.statusBarView?.backgroundColor = WalletColors.mainColor
            UIApplication.shared.statusBarStyle = .lightContent
            return
        }
        navigationController?.isNavigationBarHidden = isHide
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = WalletColors.mainColor
        UIApplication.shared.statusBarView?.backgroundColor = .white
        UIApplication.shared.statusBarStyle = .default
    }
    
    @IBAction func seeAll() {
        tabBarController?.selectedIndex = 1
        HistoryMediator.addr = selectedContact.address
    }

    private func configureTableView() {
        tableVIew.delegate = self
        tableVIew.dataSource = self
        tableVIew.register(UINib(nibName: TransactionInfoCell.identifer, bundle: nil), forCellReuseIdentifier: TransactionInfoCell.identifer)
        tableVIew.backgroundColor = WalletColors.bgMainColor
        tableVIew.isScrollEnabled = false
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


    

    //MARK: - IBAction

    @IBAction func sendFunds() {
        self.performSegue(withIdentifier: "isFromContact", sender: nil)
    }


    @IBAction func shareContact() {
        let text = "Name:\n\(selectedContact!.name)\nAddress:\n\(selectedContact!.address)"
        let activity = UIActivityViewController.activity(content: text)
        if let popOver = activity.popoverPresentationController {
            popOver.sourceView = view
            popOver.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0)
            popOver.permittedArrowDirections = []
            present(activity, animated: true)
            return
        }
        present(activity, animated: true)
    }

}

extension ProfileContactViewController:EditViewContollerDelegate {
    func didUpdateContact(name: String, address: String) {
        selectedContact = service.getAddressByAddress(address)
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
        return transactions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableVIew.dequeueReusableCell(withIdentifier: TransactionInfoCell.identifer, for: indexPath) as! TransactionInfoCell
        cell.transaction = transactions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 53.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}




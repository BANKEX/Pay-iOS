//
//  WalletTabController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 3/15/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit



class WalletTabController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    
    var editEnabled: Bool = false
    
    let service: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    var etherToken: ERC20TokenModel?
    var tokens = [ERC20TokenModel]()
    var sendEthService: SendEthService!
    var transactionsToShow = [ETHTransactionModel]()
    let keysService: SingleKeyService  = SingleKeyServiceImplementation()
    
    let interactor = Interactor()
    
    var walletData = WalletData()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let conversionService = FiatServiceImplementation.service
        conversionService.updateConversionRate(for: service.selectedERC20Token().symbol) { (rate) in
            print(rate)
        }
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeNetwork.notificationName(), object: nil, queue: nil) { (_) in
            self.updateTableView()
        }
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeWallet.notificationName(), object: nil, queue: nil) { (_) in
            self.updateTableView()
        }
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeToken.notificationName(), object: nil, queue: nil) { (_) in
            self.updateTableView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableView()
    }
    
    func updateTableView() {
        let dataQueue = DispatchQueue.global(qos: .utility)
        dataQueue.async {
            self.walletData.update(callback: { (etherToken, transactions, availableTokens) in
                DispatchQueue.main.async {
                    self.etherToken = etherToken
                    self.transactionsToShow = transactions
                    self.tokens = availableTokens
                    self.tableView.reloadData()
                }
                
            })
        }
    }

    // MARK: Table view methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == WalletSections.ethereum.rawValue {
            return 1
        } else if section == WalletSections.recentTransations.rawValue {
            return transactionsToShow.count
        } else {
            return (tokens.count)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == WalletSections.ethereum.rawValue {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TokensListCell", for: indexPath) as! TokensListCell
            guard let token = etherToken else {return cell}
            let isSelected = token.address == service.selectedERC20Token().address
            cell.configure(with: token, isSelected: isSelected, isEtherCoin: true, isEditing: false)
            return cell
            
        } else if indexPath.section == WalletSections.recentTransations.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryCell", for: indexPath) as! TransactionHistoryCell
            cell.configure(withTransaction: transactionsToShow[indexPath.row])
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TokensListCell", for: indexPath) as! TokensListCell
            let token = tokens[indexPath.row]
            let isSelected = token.address == service.selectedERC20Token().address
            cell.configure(with: token, isSelected: isSelected, isEtherCoin: false, isEditing: editEnabled)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 116
        } else if indexPath.section == 1 {
            return 53
        } else {
            return 127
        }
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let token = tokens?[indexPath.row] else {
//            return
//        }
//        let address = token.address
//        service.updateSelectedToken(to: address)
//        tokens = service.availableTokensList()
//        tableView.reloadData()
//    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == WalletSections.ethereum.rawValue {
            return "Ethereum"
        } else if section == WalletSections.recentTransations.rawValue {
            return "Recent Transactions"
        } else {
            return "Tokens"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.dataSource?.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return 0
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 10, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        headerLabel.textColor = UIColor.black
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView

    }
    
    // MARK: Table view methods
    
    @IBAction func editButtonTouched(_ sender: UIButton) {
        editEnabled = !editEnabled
        editButton.setTitle(editEnabled ? "Cancel" : "Edit", for: .normal)
        tableView.reloadData()
    }
    
    @IBAction func deleteTokenTouched(_ sender: UIButton) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete",
                                      style: .destructive,
                                      handler: { (action) in
            guard let address = sender.titleLabel?.text else { return }
            // TODO: it's not working
            print("delete tapped")
            self.service.deleteToken(with: address)
            self.updateTableView()
        }))
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: nil))
        
        self.present(alert, animated: true, completion: nil)

        
    }
    
    @IBAction func infoTokenTouched(_ sender: TokensListCellButtonInfo) {
        guard let address = sender.chosenToken else { return }
        print(address)
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? TokenInfoViewController {
            destinationViewController.transitioningDelegate = self
            //destinationViewController.tokenInfo = ["Address":"]
            destinationViewController.interactor = interactor
        }
    }
    
}

extension WalletTabController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

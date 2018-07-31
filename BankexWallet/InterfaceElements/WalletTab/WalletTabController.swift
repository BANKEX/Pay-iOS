//
//  WalletTabController.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 23.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
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
    
    let interactor = Interactor()
    
    var walletData = WalletData()
    
    var chosenToken: ERC20TokenModel?
    var chosenTokenAmount: String?
    
    @IBAction func editButtonTouched(_ sender: UIButton) {
        editEnabled = !editEnabled
        editButton.setTitle(editEnabled ? "Cancel" : "Edit", for: .normal)
        tableView.reloadData()
    }
    
    @IBAction func deleteTokenTouched(_ sender: TokensListCellButton) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete",
                                      style: .destructive,
                                      handler: { (action) in
                                        guard let address = sender.chosenToken?.address else { return }
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
    
    @IBAction func infoTokenTouched(_ sender: TokensListCellButton) {
        guard let tokenForInfo = sender.chosenToken else { return }
        chosenToken = tokenForInfo
        chosenTokenAmount = sender.amount
        // TODO: - Add token amount
        chosenTokenAmount = nil
    }
    
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
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        updateTableView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? TokenInfoController {
            destinationViewController.transitioningDelegate = self
            destinationViewController.token = chosenToken ?? nil
            destinationViewController.interactor = interactor
            destinationViewController.amount = chosenTokenAmount
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
            if transactionsToShow.count == 0 {
                return 1
            } else {
                return transactionsToShow.count
            }
            
        } else {
            if tokens.count == 0 {
                return 1
            } else {
                return tokens.count
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == WalletSections.ethereum.rawValue {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTabTokenCell", for: indexPath) as! WalletTabTokenCell
            guard let token = etherToken else {return cell}
            let isSelected = token.address == service.selectedERC20Token().address
            cell.configure(with: token, isSelected: isSelected, isEtherCoin: true, isEditing: false)
            return cell
            
        } else if indexPath.section == WalletSections.recentTransations.rawValue {
            if transactionsToShow.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptySectionCell", for: indexPath) as! EmptySectionCell
                cell.configure(with: "Send or receive funds to see all your transaction history")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryCell", for: indexPath) as! TransactionHistoryCell
                cell.configure(withTransaction: transactionsToShow[indexPath.row])
                return cell
            }
            
            
        } else {
            if tokens.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptySectionCell", for: indexPath) as! EmptySectionCell
                cell.configure(with: "Add tokens to see them here")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTabTokenCell", for: indexPath) as! WalletTabTokenCell
                let token = tokens[indexPath.row]
                let isSelected = token.address == service.selectedERC20Token().address
                cell.configure(with: token, isSelected: isSelected, isEtherCoin: false, isEditing: editEnabled)
                return cell
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 136
        } else if indexPath.section == 1 {
            if transactionsToShow.count == 0 {
                return 112
            } else {
                return 55
            }
        } else {
            if tokens.count == 0 {
                return 112
            } else {
                return 147
            }
            
        }
    }
    
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
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 32, width:
            tableView.bounds.size.width, height: 22))
        headerLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        headerLabel.textColor = UIColor.black
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        
        headerView.addSubview(headerLabel)
        
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
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

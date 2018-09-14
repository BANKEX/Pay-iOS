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
    let conversionService = FiatServiceImplementation.service
    var etherToken: ERC20TokenModel?
    var tokens = [ERC20TokenModel]()
    var sendEthService: SendEthService!
    var transactionsToShow = [ETHTransactionModel]()
    
    let interactor = Interactor()
    
    var walletData = WalletData()
    
    var chosenToken: ERC20TokenModel?
    
    @IBAction func editButtonTouched(_ sender: UIButton) {
        editEnabled = !editEnabled
        editButton.setTitle(editEnabled ? NSLocalizedString("Cancel", comment: "") : NSLocalizedString("Edit", comment: ""), for: .normal)
        tableView.reloadData()
    }
    
    @IBAction func deleteTokenTouched(_ sender: TokensListCellButton) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""),
                                      style: .destructive,
                                      handler: { (action) in
                                        guard let address = sender.chosenToken?.address else { return }
                                        // TODO: it's not working
                                        self.service.deleteToken(with: address)
                                        if let viewWithTag = self.view.viewWithTag(777) {
                                            viewWithTag.removeFromSuperview()
                                        }
                                        self.updateTableView()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                      style: .cancel,
                                      handler: {action in
                                        if let viewWithTag = self.view.viewWithTag(777) {
                                            viewWithTag.removeFromSuperview()
                                        }
        }))
        let darknessView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        darknessView.tag = 777
        darknessView.backgroundColor = UIColor.gray
        darknessView.alpha = 0.5
        self.view.insertSubview(darknessView, at: self.view.subviews.count)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func infoTokenTouched(_ sender: TokensListCellButton) {
        guard let tokenForInfo = sender.chosenToken else { return }
        chosenToken = tokenForInfo
    }
    
    @objc func addNewTokenButtonTapped() {
        self.performSegue(withIdentifier: "showAddNewToken", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editButton.accessibilityLabel = "edit"
        title = NSLocalizedString("Wallet", comment: "")
        NotificationCenter.default.addObserver(forName: ReceiveRatesNotification.receivedAllRates.notificationName(), object: nil, queue: nil) { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeNetwork.notificationName(), object: nil, queue: nil) { (_) in
            DispatchQueue.main.async {
                self.updateTableView()
            }
            
        }
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeWallet.notificationName(), object: nil, queue: nil) { (_) in
            DispatchQueue.main.async {
                self.updateTableView()
            }
        }
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeToken.notificationName(), object: nil, queue: nil) { (_) in
            DispatchQueue.main.async {
                self.updateTableView()
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        service.updateConversions()
        editEnabled = false
        editButton.setTitle(editEnabled ? NSLocalizedString("Cancel", comment: "") : NSLocalizedString("Edit", comment: ""), for: .normal)
        updateTableView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func updateTableView() {
        let dataQueue = DispatchQueue.main
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
            destinationViewController.token = chosenToken ?? nil
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
            cell.configure(with: token, isSelected: isSelected, isEtherCoin: true, isEditing: false, withConversionRate: conversionService.currentConversionRate(for: token.symbol.uppercased()))
            return cell
            
        } else if indexPath.section == WalletSections.recentTransations.rawValue {
            if transactionsToShow.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptySectionCell", for: indexPath) as! EmptySectionCell
                cell.configure(with: NSLocalizedString("Send or receive funds to see all your transaction history", comment: ""))
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryCell", for: indexPath) as! TransactionHistoryCell
                cell.configure(withTransaction: transactionsToShow[indexPath.row])
                return cell
            }
            
            
        } else {
            if tokens.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptySectionCell", for: indexPath) as! EmptySectionCell
                cell.configure(with: NSLocalizedString("Add tokens to see them here", comment: ""))
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTabTokenCell", for: indexPath) as! WalletTabTokenCell
                let token = tokens[indexPath.row]
                let isSelected = token.address == service.selectedERC20Token().address
                //cell.configure(with: token, isSelected: isSelected, isEtherCoin: false, isEditing: editEnabled)
                cell.configure(with: token, isSelected: isSelected, isEtherCoin: false, isEditing: editEnabled, withConversionRate: conversionService.currentConversionRate(for: token.symbol.uppercased()))
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
            return NSLocalizedString("Recent Transactions", comment: "")
        } else {
            return NSLocalizedString("Tokens", comment: "")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 32, width:
            tableView.bounds.size.width - 140, height: 22))
        headerLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        headerLabel.textColor = UIColor.black
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerView.addSubview(headerLabel)
        if self.tableView(self.tableView, titleForHeaderInSection: section) == NSLocalizedString("Tokens", comment: "") {
            let headerButton = UIButton(frame: CGRect(x: tableView.bounds.size.width - 135, y: 32, width: 120, height: 22))
            headerButton.setTitle(NSLocalizedString("Add new token", comment: ""), for: .normal)
            headerButton.addTarget(self, action: #selector(addNewTokenButtonTapped), for: .touchUpInside)
            headerButton.setTitleColor(WalletColors.blueText.color(), for: .normal)
            headerButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            headerButton.titleLabel?.textAlignment = .right
            headerButton.accessibilityLabel = "AddNewTokenBtn"
            headerView.addSubview(headerButton)
        }
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

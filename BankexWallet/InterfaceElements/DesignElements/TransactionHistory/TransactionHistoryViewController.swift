//
//  TransactionHistoryViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 30/07/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class TransactionHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChooseTokenDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var tokensButton: UIButton!
    var popover: UIPopoverPresentationController!
    
    var sendEthService: SendEthService = SendEthServiceImplementation()
    let tokensService: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    
    var transactionsToShow = [[ETHTransactionModel]]()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTransactions()
        configureRefreshControl()
        addTokensButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.title = "Transactions"
        } else {
            // Fallback on earlier versions
        }
        //navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }

    }
    
    //MARK: - Refresh Control
    func configureRefreshControl() {
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //TODO: - Update the data here
        tableView.reloadData()
        refreshControl.endRefreshing()
        
    }
    
    //MARK: - IBActions
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func addTokensButton() {
        tokensButton = UIButton(type: .custom)
        tokensButton.setImage(UIImage(named: "Arrow Down"), for: .normal)
        tokensButton.imageEdgeInsets = UIEdgeInsetsMake(0, 80, 0, 0)
        tokensButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        tokensButton.setTitle("ETH", for: .normal)
        tokensButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        tokensButton.setTitleColor(WalletColors.blueText.color(), for: .normal)
        tokensButton.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: tokensButton)
        tokensButton.addTarget(self, action: #selector(showTokensButtonTapped), for: .touchUpInside)
    }
    
    @objc func showTokensButtonTapped(_ sender: Any) {
        guard let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "TokensListController") as? TokensListForPopoverViewController else { return }
        popoverContent.tokens = tokensService.availableTokensList() ?? []
        popoverContent.delegate = self
        popoverContent.preferredContentSize = CGSize(width: 100, height: 150)
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = .popover
        popover = nav.popoverPresentationController
        popover.delegate = self
        popover.barButtonItem = navigationItem.rightBarButtonItem
        popover.permittedArrowDirections = .up
        popover.backgroundColor = #colorLiteral(red: 0.8549019608, green: 0.8549019608, blue: 0.8549019608, alpha: 1)
        
        self.present(nav, animated: true, completion: nil)
        
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            updateTransactions(status: .all)
        case 1:
            updateTransactions(status: .received)
        case 2:
            updateTransactions(status: .sent)
        case 3:
            updateTransactions(status: .confirming)
        default:
            print("This is not possible")
        }
        tableView.reloadData()
    }
    
    //MARK: - Choose Token Delegate
    func didSelectToken(name: String) {
        tokensButton.setTitle(name.uppercased(), for: .normal)
        popover.dismissalTransitionDidEnd(true)
        if name.uppercased() == "ETH" {
            sendEthService = SendEthServiceImplementation()
        } else {
            sendEthService = ERC20TokenContractMethodsServiceImplementation()
        }
        updateTransactions()
        tableView.reloadData()
    }
    
    //MARK: - TableView Delegate/Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionsToShow[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionsToShow.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 46))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 22))
        label.text = getDateForPrint(date: transactionsToShow[section][0].date)
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        view.backgroundColor = UIColor.white
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 26))
        view.backgroundColor = UIColor.white
        return view
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "transactionHistoryCell") as? TransactionHistoryCell else { return UITableViewCell() }
        cell.configure(withTransaction: transactionsToShow[indexPath.section][indexPath.row])
        return cell
    }
    
    //MARK: Popover Delegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //MARK: - Helpers
    private func getFormattedDate(date: Date) -> (day: Int, month: Int, year: Int) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        return (day, month, year)
    }
    
    private func getDateForPrint(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    private func updateTransactions(status: TransactionStatus = .all) {
        var transactions: [ETHTransactionModel]
        transactionsToShow.removeAll()
        guard let selectedAddress = SingleKeyServiceImplementation().selectedAddress() else { return }
        switch status {
        case .all:
            transactions = sendEthService.getAllTransactions()!
        case .sent:
            transactions = sendEthService.getAllTransactions()!.filter{ $0.from == selectedAddress }
        case .received:
            transactions = sendEthService.getAllTransactions()!.filter{ $0.from != selectedAddress }
        case .confirming:
            transactions = []
        }
        for transaction in transactions {
            let trDate = getFormattedDate(date: transaction.date)
            if transactionsToShow.isEmpty {
                transactionsToShow.append([transaction])
            } else {
                guard let last = transactionsToShow.last?.last else { return }
                let lastTrDate = getFormattedDate(date: last.date)
                if lastTrDate.year == trDate.year && lastTrDate.month == trDate.month && lastTrDate.day == trDate.day {
                    transactionsToShow[transactionsToShow.count - 1].append(transaction)
                } else {
                    transactionsToShow.append([transaction])
                }
            }
        }
    }
}

enum TransactionStatus {
    case all
    case sent
    case received
    case confirming
}

//
//  TransactionHistoryViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 30/07/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import Popover

class TransactionHistoryViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, ChooseTokenDelegate, UIPopoverPresentationControllerDelegate {
    
    enum State {
        case empty,fill
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView:UIView!
    var tokensButton: UIButton!
    var popover: Popover!
    //Save height of popover when appear 5 tokens
    var fiveTokensHeight:CGFloat = 0
    var tokensTableViewManager = TokensTableViewManager()
    var selectedAddress:String?
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
        .arrowSize(CGSize(width: 29, height: 16)),
        .cornerRadius(8.0)
    ]
    var state:State = .empty {
        didSet {
            if state == .empty {
                tableView.isHidden = true
                emptyView.isHidden = false
            }else {
                tableView.isHidden = false
                emptyView.isHidden = true
            }
        }
    }
    var sendEthService: SendEthService!
    let tokensService: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    let transactionsService = TransactionsService()
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    
    var transactionsToShow = [[ETHTransactionModel]]()
    var currentState: TransactionStatus = .all
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        prepareNavBar()
        configureRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSendEthService()
        updateTransactions()
        updateUI()
    }
    
    func updateUI() {
        state = transactionsToShow.isEmpty ? .empty : .fill
    }
    
    
    func setupTableView() {
        tableView.backgroundColor = WalletColors.bgMainColor
        tableView.register(UINib(nibName: TransactionInfoCell.identifer, bundle: nil), forCellReuseIdentifier: TransactionInfoCell.identifer)
    }
    
    private func prepareNavBar() {
        addTokensButton()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    //MARK: - Refresh Control
    func configureRefreshControl() {
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        }
    }
    
    
    func calculateHeight() -> CGFloat {
        let heightOfToken:CGFloat = 23
        guard let tokens = tokensService.availableTokensList() else { return 0 }
        if tokens.count > 5 {
            return fiveTokensHeight
        }else {
            let height = tokens.count * Int(heightOfToken)
            fiveTokensHeight = CGFloat(height).next(number: tokens.count)
            return CGFloat(height).next(number: tokens.count)
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //TODO: - Update the data here
        guard let selectedAddress = keysService.selectedAddress() else { return }
        transactionsService.refreshTransactionsInSelectedNetwork(forAddress: selectedAddress) { (success) in
            if success {
                self.updateTransactions(status: self.currentState)
                self.tableView.reloadData()
                self.updateUI()
            }
            refreshControl.endRefreshing()
        }
    }
    
    //MARK: - Popover magic
    @objc func showTokensButtonTapped(_ sender: Any) {
        popover = Popover(options: self.popoverOptions)
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: 86, height: calculateHeight()))
        aView.clipsToBounds = true
        aView.backgroundColor = UIColor.clear
//        let tableView = UITableView(frame: CGRect(x: 0, y: 5, width: 100, height: calculateHeight()), style: .plain)
        let tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: 10, width: aView.bounds.width, height: aView.bounds.height)
        tableView.separatorStyle = .none
        tableView.clipsToBounds = true
        let v = UIView()
        v.frame.size.height = 5
        tableView.tableHeaderView = v
        tableView.showsVerticalScrollIndicator = false
        tableView.layer.cornerRadius = 8.0
        aView.addSubview(tableView)
        let point = CGPoint(x: UIScreen.main.bounds.width - 29, y: 50)
        tokensTableViewManager.delegate = self
        tableView.delegate = tokensTableViewManager
        tableView.dataSource = tokensTableViewManager
        self.popover.show(aView, point: point)
        
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
        updateUI()
    }
    
    //MARK: - Choose Token Delegate
    func didSelectToken(name: String) {
        popover.dismiss()
        guard let token = tokensService.availableTokensList()?.filter({$0.symbol.uppercased() == name.uppercased()}).first else { return }
        tokensService.updateSelectedToken(to: token.address, completion: {
            self.tokensButton.setTitle(name.uppercased(), for: .normal)
            self.updateTransactions(status: self.currentState)
            self.tableView.reloadData()
            self.updateUI()
        })
        
    }
    
    //MARK: - TableView Delegate/Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionsToShow[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionsToShow.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 53))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 22))
        label.text = getDateForPrint(date: transactionsToShow[section][0].date)
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        view.backgroundColor = WalletColors.bgMainColor
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        view.backgroundColor = WalletColors.bgMainColor
        return view
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionInfoCell.identifer) as? TransactionInfoCell else { return UITableViewCell() }
        cell.fromMain = false
//        cell.configure(withTransaction: transactionsToShow[indexPath.section][indexPath.row], forMain: false)
        cell.transaction = transactionsToShow[indexPath.section][indexPath.row]
        return cell
    }
    
    //MARK: Popover Delegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //MARK: - Helpers
    private func addTokensButton() {
        tokensButton = UIButton(type: .custom)
        tokensButton.setImage(UIImage(named: "Arrow Down"), for: .normal)
        tokensButton.imageEdgeInsets = UIEdgeInsetsMake(0, 80, 0, 0)
        tokensButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        let title = tokensService.selectedERC20Token().symbol.uppercased()
        tokensButton.setTitle(title, for: .normal)
        tokensButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        tokensButton.setTitleColor(WalletColors.mainColor, for: .normal)
        tokensButton.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: tokensButton)
        tokensButton.addTarget(self, action: #selector(showTokensButtonTapped), for: .touchUpInside)
    }
    
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
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date)
    }
    
    
    
    private func updateTransactions(status: TransactionStatus = .all) {
        var transactions: [ETHTransactionModel]
        transactionsToShow.removeAll()
        currentState = status
        configureSendEthService()
        guard let selectedAddress = SingleKeyServiceImplementation().selectedAddress() else { return }
        switch status {
        case .all:
            transactions = sendEthService.getAllTransactions()
        case .sent:
            transactions = sendEthService.getAllTransactions().filter{ $0.from == selectedAddress.lowercased() && !$0.isPending }
        case .received:
            transactions = sendEthService.getAllTransactions().filter{ $0.from != selectedAddress.lowercased() && !$0.isPending}
        case .confirming:
            transactions = sendEthService.getAllTransactions().filter{ $0.isPending }
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
    
    private func configureSendEthService() {
        print(tokensService.selectedERC20Token().symbol.uppercased())
        sendEthService = tokensService.selectedERC20Token().symbol.uppercased() == "ETH" ? SendEthServiceImplementation() :  ERC20TokenContractMethodsServiceImplementation()
    }
}


enum TransactionStatus {
    case all
    case sent
    case received
    case confirming
}

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
    @IBOutlet weak var segmentControl:UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView:UIView!
    var tokenView: TokenArrow!
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
    var fromContact:Bool {
        return HistoryMediator.addr != nil
    }
    var transactionsToShow = [[ETHTransactionModel]]()
    var currentState: TransactionStatus = .all
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        TransactionsService().refreshTransactionsInSelectedNetwork(type: nil, forAddress: keysService.selectedAddress()!, node: nil, completion: { _ in })
        setupTableView()
        configureRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareNavBar()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSendEthService()
        if fromContact {
            updateTransactions(address: HistoryMediator.addr!, status: .all)
        } else {
            updateTransactions()
        }
        updateUI()
    }
    
    func updateUI() {
        state = transactionsToShow.isEmpty ? .empty : .fill
        tableView.reloadData()
    }
    
    
    func setupTableView() {
        tableView.backgroundColor = UIColor.bgMainColor
        tableView.register(UINib(nibName: TransactionInfoCell.identifer, bundle: nil), forCellReuseIdentifier: TransactionInfoCell.identifer)
        tableView.separatorInset.left = 50
    }
    
    private func prepareNavBar() {
        addTokensButton()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        UIApplication.shared.statusBarView?.backgroundColor = .white
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
            return CGFloat(5 * Int(heightOfToken)).next(number: tokens.count)
        }else {
            let height = tokens.count * Int(heightOfToken)
            fiveTokensHeight = CGFloat(height).next(number: tokens.count)
            return CGFloat(height).next(number: tokens.count)
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //TODO: - Update the data here
        guard let selectedAddress = HistoryMediator.addr ?? keysService.selectedAddress() else { return }
        transactionsService.refreshTransactionsInSelectedNetwork(type: nil, forAddress: selectedAddress, node: nil) { (success) in
            if success {
                self.updateTransactions(address: selectedAddress, status: self.currentState)
                self.updateUI()
            }
            refreshControl.endRefreshing()
        }
    }
    
    //MARK: - Popover magic
    @objc func showTokensButtonTapped(_ sender: Any) {
        popover = Popover(options: self.popoverOptions)
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: UIDevice.isIpad ? 320 : 86, height: calculateHeight()))
        aView.clipsToBounds = true
        aView.backgroundColor = UIColor.clear
//        let tableView = UITableView(frame: CGRect(x: 0, y: 5, width: 100, height: calculateHeight()), style: .plain)
        let tableView = UITableView()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        tableView.frame = CGRect(x: 0, y: 10, width: aView.bounds.width, height: aView.bounds.height)
        tableView.separatorStyle = UIDevice.isIpad ? .singleLine : .none
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
        var selAddr = HistoryMediator.addr ?? SingleKeyServiceImplementation().selectedAddress()!
        switch sender.selectedSegmentIndex {
        case 0:
            updateTransactions(address: selAddr, status: .all)
        case 1:
            updateTransactions(address: selAddr, status: .received)
        case 2:
            updateTransactions(address: selAddr, status: .sent)
        case 3:
            updateTransactions(address: selAddr, status: .confirming)
        default:
            print("This is not possible")
        }
        updateUI()
    }
    
    //MARK: - Choose Token Delegate
    func didSelectToken(name: String) {
        popover.dismiss()
        let selAddr = HistoryMediator.addr ?? SingleKeyServiceImplementation().selectedAddress()!
        guard let token = tokensService.availableTokensList()?.filter({$0.symbol.uppercased() == name.uppercased()}).first else { return }
        tokensService.updateSelectedToken(to: token.address, completion: {
            self.tokenView.tokenSymbol = name.uppercased()
            self.updateTransactions(address: selAddr, status: self.currentState)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        HistoryMediator.addr = nil
        segmentControl.selectedSegmentIndex = 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 53))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 22))
        label.text = getDateForPrint(date: transactionsToShow[section][0].date)
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.separatorColor
        view.backgroundColor = UIColor.bgMainColor
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        view.backgroundColor = UIColor.bgMainColor
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
        tokenView = TokenArrow.loadFromNib()
        tokenView.tokenSymbol = tokensService.selectedERC20Token().symbol.uppercased()
        tokenView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showTokensButtonTapped)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: tokenView)
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
        let selectedAddress = SingleKeyServiceImplementation().selectedAddress()!
        updateTransactions(address: selectedAddress, status: status)
    }
    
    private func updateTransactions(address:String, status: TransactionStatus = .all) {
        var transactions: [ETHTransactionModel]
        transactionsToShow.removeAll()
        currentState = status
        configureSendEthService()
            switch status {
            case .all:
                transactions = sendEthService.getAllTransactions(addr: address)
            case .sent:
                transactions = sendEthService.getAllTransactions(addr: address).filter{ $0.from == address.lowercased() && !$0.isPending }
            case .received:
                transactions = sendEthService.getAllTransactions(addr: address).filter{ $0.from != address.lowercased() && !$0.isPending}
            case .confirming:
                transactions = sendEthService.getAllTransactions(addr: address).filter{ $0.isPending }
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


enum TransactionStatus:Int {
    case all
    case sent
    case received
    case confirming
}

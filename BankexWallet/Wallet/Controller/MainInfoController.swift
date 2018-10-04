//
//  MainInfoController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/4/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import BigInt
import web3swift

enum PredefinedTokens {
    case Bankex
    case BNB
    case Bytom
    case DGD
    case EOS
    case Ethereum
    case ICON
    case LiteCoin
    case OmiseGo
    case Populous
    case Ripple
    case Thronix
    case VeChain
    case NotDefined
    
    func image() -> UIImage {
        switch self {
        case .Bankex:
            return #imageLiteral(resourceName: "Bankex")
        case .BNB:
            return #imageLiteral(resourceName: "BNB")
        case .Bytom:
            return #imageLiteral(resourceName: "Bytom")
        case .DGD:
            return #imageLiteral(resourceName: "DGD")
        case .EOS:
            return #imageLiteral(resourceName: "EOS")
        case .Ethereum:
            return #imageLiteral(resourceName: "Ethereum")
        case .ICON:
            return #imageLiteral(resourceName: "ICON")
        case .LiteCoin:
            return #imageLiteral(resourceName: "Litecoin")
        case .OmiseGo:
            return #imageLiteral(resourceName: "OmiseGo")
        case .Populous:
            return #imageLiteral(resourceName: "Populous")
        case .Ripple:
            return #imageLiteral(resourceName: "Ripple")
        case .Thronix:
            return #imageLiteral(resourceName: "Tronix")
        case .VeChain:
            return #imageLiteral(resourceName: "VeChain")
        default:
            return #imageLiteral(resourceName: "Other coins")
        }
    }
    
    init(with symbol: String) {
        switch symbol.lowercased() {
        case "eth":
            self = .Ethereum
        case "bkx":
            self = .Bankex
        case "bnb":
            self = .BNB
        case "bytom":
            self = .Bytom
        case "dgd":
            self = .DGD
        default:
            self = .NotDefined
        }
    }
}

class MainInfoController: BaseViewController,
    UITabBarControllerDelegate,UITableViewDataSource, UITableViewDelegate, InfoViewDelegate {
    
    @IBOutlet weak var infoView:InfoView!
    @IBOutlet weak var sendButton:UIButton!
    @IBOutlet weak var receiveButton:UIButton!
    @IBOutlet weak var emptyView:UIView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var listTransButton:BaseButton!
    
    let keyService = SingleKeyServiceImplementation()
    var numberFormatter:NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "en_GB")
        numberFormatter.currencySymbol = "$"
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 5
        return numberFormatter
    }
    var ethLabel: UILabel!
    var service = RecipientsAddressesServiceImplementation()
    
    var sendEthService: SendEthService!
    let tokensService = CustomERC20TokensServiceImplementation()
    
    var transactionsToShow = [ETHTransactionModel]()
    var transactionInitialDiff = 0
    var selectedToken:ERC20TokenModel?
    var utilsService:UtilTransactionsService!
    var rateSevice = FiatServiceImplementation()
    var transactions = [ETHTransactionModel]()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        [sendButton,receiveButton].forEach { $0?.callShadow() }
        infoView.delegate = self
        sendEthService = selectedToken!.address.isEmpty ?
            SendEthServiceImplementation() :
            ERC20TokenContractMethodsServiceImplementation()
        self.transactions = Array(self.sendEthService.getAllTransactions(addr:nil).prefix(3))
//        configureRefreshControl()
//        tokensService.updateConversions()
        configureNotifications()
        
        //sendFackTrans()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
        updateBalance()
        updateRate()
        updateDataOnTheScreen()
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
        UIApplication.shared.statusBarView?.backgroundColor = .white
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        // testing dynamic links
        //self.tabBarController?.selectedIndex = AppDelegate.initiatingTabBar.rawValue
        AppDelegate.initiatingTabBar = .main
        //
    }
    
//    func sendFackTrans() {
//        let sendEth = SendEthServiceImplementation()
//        sendEth.prepareTransactionForSending(destinationAddressString: keyService.selectedWallet()!.address, amountString: "0.001") { (result) in
//            switch result {
//            case .Success(let response):
//                var transaction = response
//                let token = self.tokensService.selectedERC20Token()
//                let model = ETHTransactionModel(from:self.keyService.selectedWallet()!.address, to: "0xfa8Ccb56c93F6f6682F89098d5D4f372e3c22504", amount: "0.001", date: Date(), token: token, key: self.keyService.selectedKey()!, isPending: true)
//                var options = Web3Options.defaultOptions()
//                options.gasLimit = BigUInt("21000")
//                let gp = BigUInt(Double("20")! * pow(10, 9))
//                options.gasPrice = gp
//                options.from = transaction.options?.from
//                options.to = transaction.options?.to
//                options.value = transaction.options?.value
//                sendEth.send(transactionModel: model, transaction: transaction, options: options, completion: { (result) in
//                    print("OK")
//                })
//            default:break
//            }
//        }
//
//    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorColor = WalletColors.disableColor
        tableView.separatorInset.left = 42.0
        tableView.register(UINib(nibName: TransactionInfoCell.identifer, bundle: nil), forCellReuseIdentifier: TransactionInfoCell.identifer)
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
    }
    
    
    private func updateUI() {
//        guard let selToken = selectedToken else { return }
        let selToken = tokensService.selectedERC20Token()
        infoView.state = selToken.name == "Ether" ? .Eth : .Token
        updateSymbol()
        updateWalletName()
        updateWalletAddr()
        updateTokenName()
        if self.transactions.isEmpty {
            self.emptyView.isHidden = false
            self.tableView.isHidden = true
            self.listTransButton.isHidden = true
        }else {
            self.emptyView.isHidden = true
            self.tableView.isHidden = false
            self.listTransButton.isHidden = false
        }
    }
    
    private func updateTokenName() {
        guard let selectedToken = selectedToken else { return }
        infoView.tokenNameLabel?.text = selectedToken.name
    }
    
    private func updateRate() {
        guard let selectedToken = selectedToken else { return }
        let tokenName = selectedToken.symbol.uppercased()
        self.rateSevice.updateConversionRate(for: tokenName, completion: { (result) in
            guard let balanceString = self.infoView.balanceLabel.text else { return }
            guard let rateCurrency = balanceString.formatToDollar(rate: result) else { return }
            self.infoView.rateLabel.text = "\(self.numberFormatter.string(from: NSNumber(value:rateCurrency)) ?? "") at the rate of CryptoCompare"
        })
    }
    
    private func updateWalletName() {
        guard let selToken = selectedToken else { return }
        if selToken.name == "Ether" {
            guard let wallet = keyService.selectedWallet() else { return }
            infoView.nameWallet.text = wallet.name
        }
    }
    private func updateWalletAddr() {
        guard let selToken = selectedToken else { return }
        if selToken.name == "Ether" {
            guard let wallet = keyService.selectedWallet() else { return }
            infoView.addrWallet.text = wallet.address.formattedAddrToken()
        }
    }
    
    private func updateSymbol() {
        guard let selToken = selectedToken else { return }
        let symbol = selToken.symbol.uppercased()
        infoView.nameTokenLabel.text = symbol
    }
    
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func updateBalance() {
        utilsService = selectedToken!.address.isEmpty ? UtilTransactionsServiceImplementation() :
            CustomTokenUtilsServiceImplementation()
        guard let selectedAddress = keyService.selectedAddress() else {
            return
        }
        utilsService.getBalance(for: selectedToken!.address, address: selectedAddress) { (result) in
            switch result {
            case .Success(let response):
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                DispatchQueue.global(qos: .userInitiated).async {
                    let formattedAmount = Web3.Utils.formatToEthereumUnits(response,
                                                                           toUnits: .eth,
                                                                           decimals: 8,
                                                                           fallbackToScientific: true)
                    DispatchQueue.main.async {
                        self.infoView.balanceLabel.text = formattedAmount!
                        if self.infoView.isEmptyBalance {
                            self.infoView.rateLabel.isHidden = true
                        }
                    }
                }
            case .Error(let error):
                self.infoView.balanceLabel.text = "..."
                print("\(error)")
            }
        }
    }
    
    
    
    
    
        
    @IBAction func unwind(segue:UIStoryboardSegue) { }
    
    
    @IBAction func seeOrAddContactsButtonTapped(_ sender: UIButton) {
        if sender.title(for: .normal) == NSLocalizedString("See All", comment: ""){
            self.performSegue(withIdentifier: "seeAllFavorites", sender: nil)
        } else {
            self.performSegue(withIdentifier: "addNewFavorite", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AddressQRCodeController {
            let keyService: GlobalWalletsService = SingleKeyServiceImplementation()
            controller.addressToGenerateQR = keyService.selectedAddress()
        } else if let controller = segue.destination as? SendTokenViewController {
            controller.selectedFavoriteAddress = selectedFavAddress
            controller.selectedFavoriteName = selectedFavName
            selectedFavAddress = nil
            selectedFavName = nil
            controller.selectedToken = self.selectedToken
            controller.currentBalance = infoView.balanceLabel.text
        }
    }
    
    
    
    //MARK: - Helpers
    func putTransactionsInfoIntoItemsArray() {
        guard let selectedToken = selectedToken else { return }
        sendEthService = selectedToken.address.isEmpty ?
            SendEthServiceImplementation() :
            ERC20TokenContractMethodsServiceImplementation()
        transactionsToShow = Array(sendEthService.getAllTransactions(addr:nil).prefix(3))
        var arrayOfTransactions = [String]()
        switch transactionsToShow.count {
        case 0:
            arrayOfTransactions = ["EmptyLastTransactionsCell"]
        case 1:
            arrayOfTransactions = ["TopRoundedCell", "LastTransactionHistoryCell","BottomRoundedCell"]
        case 2:
            arrayOfTransactions = ["TopRoundedCell", "LastTransactionHistoryCell", "LastTransactionHistoryCell", "BottomRoundedCell"]
        default:
            arrayOfTransactions = ["TopRoundedCell", "LastTransactionHistoryCell", "LastTransactionHistoryCell", "LastTransactionHistoryCell", "BottomRoundedCell"]
        }
        
//        let index = itemsArray.index{$0 == "TransactionHistoryCell"} ?? 0
//        transactionInitialDiff = index + 2
//        itemsArray.insert(contentsOf: arrayOfTransactions, at: index + 1)
//        itemsArray.append(contentsOf: arrayOfFavorites)
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarView?.backgroundColor = WalletColors.mainColor
        UIApplication.shared.statusBarStyle = .lightContent
//        getBlockNumber { (number) in
//            self.configureLabel(withNumber: number)
//        }
    }
    
    private func createStringWithBlockNumber(blockNumber: String) -> NSAttributedString? {
        let fullString = NSMutableAttributedString(string: "")
        let attachment = NSTextAttachment()
        
        let image = UIImage(named: "GreenCircle")
        
        attachment.image = image
        let circleImageString = NSAttributedString(attachment: attachment)
        fullString.append(circleImageString)
        fullString.append(NSAttributedString(string: " Ethereum\n"))
        fullString.append(NSAttributedString(string: String(blockNumber)))
        return fullString
    }
    
    private func getBlockNumber(completion: @escaping (String) -> Void) {
        DispatchQueue.global().async {
            let web3 = WalletWeb3Factory.web3()
            let res = web3.eth.getBlockNumber()
            switch res {
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    completion("-")
                }
            case .success(let number):
                DispatchQueue.main.async {
                    completion(number.description)
                }
            }
        }
    }
    
    private func formatNumber(number: String) -> String {
        var formattedNumber = ""
        var numberOfSpaces = 0
        for el in number.reversed() {
            formattedNumber += String(el)
            if (formattedNumber.count - numberOfSpaces) % 3 == 0 {
                formattedNumber += " "
                numberOfSpaces += 1
            }
        }
        return String(formattedNumber.reversed())
    }
    
    private func configureNotifications() {
        NotificationCenter.default.addObserver(forName: ReceiveRatesNotification.receivedAllRates.notificationName(), object: nil, queue: nil) { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

        }
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeNetwork.notificationName(), object: nil, queue: nil) { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeWallet.notificationName(), object: nil, queue: nil) { (_) in
            DispatchQueue.main.async {
                self.updateUI()
                self.tableView.reloadData()
            }
        }
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeToken.notificationName(), object: nil, queue: nil) { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func deleteButtonTapped() {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        let deleteAction = UIAlertAction(title:"Delete", style: .destructive) { _ in
            guard let addr = self.selectedToken?.address else { return }
            self.tokensService.deleteToken(with: addr)
            self.navigationController?.popViewController(animated: true)
        }
        alertVC.addAction(deleteAction)
        present(alertVC, animated: true)
    }
    
    @IBAction func toQRScreen() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "qr", sender: nil)
        }
    }
    
    @IBAction func seeAll() {
        tabBarController?.selectedIndex = 1
    }
    
    private func updateDataOnTheScreen() {
            if let address = self.keyService.selectedAddress() {
                TransactionsService().refreshTransactionsInSelectedNetwork(forAddress: address) { (tr) in
//                    self.putTransactionsInfoIntoItemsArray()
                    //self.getTransactions()
                    self.transactions = Array(self.sendEthService.getAllTransactions(addr:nil).prefix(3))
                    self.tableView.reloadData()
//                    if #available(iOS 10.0, *) {
//                        self.tableView.refreshControl?.endRefreshing()
//                    }
                }
            } else {
//                if #available(iOS 10.0, *) {
//                    self.tableView.refreshControl?.endRefreshing()
//                }
            }
    }
    
    //MARK: - Refresh Control
//    func configureRefreshControl() {
//        if #available(iOS 10.0, *) {
//            tableView.refreshControl = UIRefreshControl()
//            tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
//        }
//    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //updateDataOnTheScreen()
    }
    
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transInfoCell = tableView.dequeueReusableCell(withIdentifier: TransactionInfoCell.identifer, for: indexPath) as! TransactionInfoCell
        let selectedTrans = transactions[indexPath.row]
        transInfoCell.transaction = selectedTrans
        return transInfoCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 53.0
    }
    
    
    
    // MARK: TabbarController Delegate
    // TODO:  Think about better place
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard self == viewController else {
            return
        }
        // This is just to force balance update sometimes, but think about better way maybe
        //tableView.reloadData()
    }
    
    // MARK: FavoriteSelectionDelegate
    func didSelectAddNewFavorite() {
        
    }
    
    var selectedFavAddress: String?
    var selectedFavName: String?
    func didSelectFavorite(with name: String, address: String) {
        selectedFavName = name
        selectedFavAddress = address
        performSegue(withIdentifier: "showSendFunds", sender: self)
    }
}



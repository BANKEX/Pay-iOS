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
    @IBOutlet weak var heightConstraint:NSLayoutConstraint!
    
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
    var service = ContactService()
    
    var sendEthService: SendEthService!
    let tokensService = CustomERC20TokensServiceImplementation()
    
    var transactionsToShow = [ETHTransactionModel]()
    var transactionInitialDiff = 0
    var selectedToken:ERC20TokenModel {
        return tokensService.selectedERC20Token()
    }
    var utilsService:UtilTransactionsService!
    var rateSevice = FiatServiceImplementation()
    var transactions = [ETHTransactionModel]()
    var isEtherToken:Bool {
        return selectedToken.address.isEmpty
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        commonSetup()
        sendEthService = isEtherToken ?
            SendEthServiceImplementation() :
            ERC20TokenContractMethodsServiceImplementation()
        self.transactions = Array(self.sendEthService.getAllTransactions(addr:nil).prefix(3))
        configureNotifications()
    }
    
    func commonSetup() {
        [sendButton,receiveButton].forEach { $0?.callShadow() }
        infoView.delegate = self
        let multiplier:CGFloat = UIDevice.isIpad ? 1/4.76 : 1/2.28
        heightConstraint.setMultiplier(multiplier: multiplier)
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
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        AppDelegate.initiatingTabBar = .main
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor.disableColor
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
        infoView.tokenNameLabel?.text = selectedToken.name
    }
    
    private func updateRate() {
        let tokenName = selectedToken.symbol.uppercased()
        self.rateSevice.updateConversionRate(for: tokenName, completion: { (result) in
            guard let balanceString = self.infoView.balanceLabel.text else { return }
            guard let rateCurrency = balanceString.formatToDollar(rate: result) else { return }
            self.infoView.rateLabel.text = String(format: NSLocalizedString("%@ at the rate of CryptoCompare", comment: ""), self.numberFormatter.string(from: NSNumber(value:rateCurrency)) ?? "")
        })
    }
    
    private func updateWalletName() {
        if isEtherToken {
            guard let wallet = keyService.selectedWallet() else { return }
            infoView.nameWallet.text = wallet.name
        }
    }
    private func updateWalletAddr() {
        if isEtherToken {
            guard let wallet = keyService.selectedWallet() else { return }
            infoView.addrWallet.text = wallet.address.formattedAddrToken()
        }
    }
    
    private func updateSymbol() {
        let symbol = selectedToken.symbol.uppercased()
        infoView.nameTokenLabel.text = symbol
    }
    
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func updateBalance() {
        utilsService = isEtherToken ? UtilTransactionsServiceImplementation() :
            CustomTokenUtilsServiceImplementation()
        guard let selectedAddress = keyService.selectedAddress() else {
            return
        }
        utilsService.getBalance(for: selectedToken.address, address: selectedAddress) { (result) in
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AddressQRCodeController {
            let keyService: GlobalWalletsService = SingleKeyServiceImplementation()
            controller.addressToGenerateQR = keyService.selectedAddress()
        } else if let controller = segue.destination as? SendTokenViewController {
            controller.currentBalance = infoView.balanceLabel.text
        }
    }
    
    
    
    //MARK: - Helpers
    func putTransactionsInfoIntoItemsArray() {
        sendEthService = selectedToken.address.isEmpty ?
            SendEthServiceImplementation() :
            ERC20TokenContractMethodsServiceImplementation()
        transactionsToShow = Array(sendEthService.getAllTransactions(addr:nil).prefix(3))
        var arrayOfTransactions = [String]()
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarView?.backgroundColor = nil
        UIApplication.shared.statusBarStyle = UIDevice.isIpad ? .default : .lightContent
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
        let alertStyle:UIAlertController.Style = UIDevice.isIpad ? .alert : .actionSheet
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: alertStyle)
        alertVC.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        let deleteAction = UIAlertAction(title:NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
            self.tokensService.deleteToken(with: self.selectedToken.address)
            self.navigationController?.popViewController(animated: true)
        }
        if UIDevice.isIpad {
            alertVC.title = "Delete Token"
            alertVC.message = "You are going to delete a token. This action can’t be undone."
            alertVC.addPopover(in: view, rect: CGRect(x: splitViewController!.view.bounds.midX, y: splitViewController!.view.bounds.midY - 70, width: 270, height: 140))
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
        if UIDevice.isIpad {
            selectSection(1)
        }else {
            tabBarController?.selectedIndex = 1
        }
    }
    
    private func updateDataOnTheScreen() {
            if let address = self.keyService.selectedAddress() {
                TransactionsService().refreshTransactionsInSelectedNetwork(type: nil, forAddress: address, node: nil) { (tr) in
                    self.transactions = Array(self.sendEthService.getAllTransactions(addr:nil).prefix(3))
                    self.tableView.reloadData()
                }
            }
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
    
}



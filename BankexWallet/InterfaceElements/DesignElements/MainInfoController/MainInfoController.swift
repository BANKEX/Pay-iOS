//
//  MainInfoController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/4/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import BigInt

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
        default:
            self = .NotDefined
        }
    }
}

class MainInfoController: UITableViewController,
    UITabBarControllerDelegate,
FavoriteSelectionDelegate {
    
    
    var itemsArray = [
        "CurrentWalletInfoCell",
        "TransactionHistoryCell"]
    //                      "FavouritesTitleCell",
    //                      "FavouritesListWithCollectionCell"]
    
    let keyService = SingleKeyServiceImplementation()
    var ethLabel: UILabel!
    
    var favorites: [FavoriteModel]?
    var favService:RecipientsAddressesService = RecipientsAddressesServiceImplementation()
    var favoritesToShow = [FavoriteModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        favorites = favService.getAllStoredAddresses()
        
        
        let conversionService = FiatServiceImplementation.service
        conversionService.updateConversionRate(for: tokensService.selectedERC20Token().symbol) { (rate) in
            print(rate)
        }
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeNetwork.notificationName(), object: nil, queue: nil) { (_) in
            self.tableView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeWallet.notificationName(), object: nil, queue: nil) { (_) in
            self.tableView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeToken.notificationName(), object: nil, queue: nil) { (_) in
            self.tableView.reloadData()
        }
    }
    
    var sendEthService: SendEthService!
    let tokensService = CustomERC20TokensServiceImplementation()
    
    var transactionsToShow = [ETHTransactionModel]()
    var transactionInitialDiff = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
        navigationController?.navigationBar.topItem?.prompt = "   "
        itemsArray = [
            "CurrentWalletInfoCell",
            "TransactionHistoryCell",//]
            "FavouritesTitleCell"]
        putTransactionsInfoIntoItemsArray()
        tableView.reloadData()
    }
    
        
    @IBAction func unwind(segue:UIStoryboardSegue) { }
    
    
    @IBAction func seeOrAddContactsButtonTapped(_ sender: UIButton) {
        if sender.title(for: .normal) == "See All" {
            //TODO: - perform segue to contacts screes
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
        }
    }
    
    //MARK: - Helpers
    func putTransactionsInfoIntoItemsArray() {
        sendEthService = tokensService.selectedERC20Token().address.isEmpty ?
            SendEthServiceImplementation() :
            ERC20TokenContractMethodsServiceImplementation()
        if let firstThree = sendEthService.getAllTransactions()?.prefix(3) {
            transactionsToShow = Array(firstThree)
        }
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
        var arrayOfFavorites = [String]()
        if let firstThree = favService.getAllStoredAddresses()?.prefix(3) {
            favoritesToShow = Array(firstThree)
        }
        switch favoritesToShow.count {
        case 0:
            arrayOfFavorites = ["EmptyLastContactsCell"]
        case 1:
            arrayOfFavorites = ["FavoriteContactCell"]
        case 2:
            arrayOfFavorites = ["FavoriteContactCell", "FavoriteContactCell"]
        default:
            arrayOfFavorites = ["FavoriteContactCell", "FavoriteContactCell", "FavoriteContactCell"]
            
        }
        
        let index = itemsArray.index{$0 == "TransactionHistoryCell"} ?? 0
        transactionInitialDiff = index + 2
        itemsArray.insert(contentsOf: arrayOfTransactions, at: index + 1)
        itemsArray.append(contentsOf: arrayOfFavorites)
    }
    
    
    
    func configureNavBar() {
        navigationController?.navigationBar.topItem?.title = nil
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.shadowImage = nil
        
        let nameLabel = UILabel()
        nameLabel.text = "Home"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 34.0)
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(customView: nameLabel)
        ethLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 200, height: 90))
        getBlockNumber { (number) in
            self.configureLabel(withNumber: number)
        }
        
        navigationController?.navigationBar.topItem?.setRightBarButtonItems(
            [UIBarButtonItem(customView: ethLabel)], animated: true)
    }
    
    func createStringWithBlockNumber(blockNumber: String) -> NSAttributedString? {
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
    
    func getBlockNumber(completion: @escaping (String) -> Void) {
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
    
    func configureLabel(withNumber number: String) {
        
        self.ethLabel.attributedText = self.createStringWithBlockNumber(blockNumber: formatNumber(number: number))
        self.ethLabel.numberOfLines = 2
        self.ethLabel.textAlignment = .right
        self.ethLabel.font = UIFont.systemFont(ofSize: 12)
    }
    
    func formatNumber(number: String) -> String {
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
    
    //MARK: - Refresh Control
    func configureRefreshControl() {
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //TODO: - Update the data here
        getBlockNumber { (number) in
            self.configureLabel(withNumber: number)
            self.itemsArray = [
                "CurrentWalletInfoCell",
                "TransactionHistoryCell",//]
                "FavouritesTitleCell"]
            self.putTransactionsInfoIntoItemsArray()
            self.tableView.reloadData()
            if #available(iOS 10.0, *) {
                self.tableView.refreshControl?.endRefreshing()
            }
        }
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemsArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemsArray[indexPath.row], for: indexPath)
        
        if let cell = cell as? TransactionHistoryCell {
            let indexOfTransaction = indexPath.row - transactionInitialDiff
            cell.configure(withTransaction: transactionsToShow[indexOfTransaction], isLastCell: indexOfTransaction == transactionsToShow.count - 1)
        }
        if let cell = cell as? TransactionHistorySectionCell {
            cell.showMoreButton.isHidden = transactionsToShow.count == 0
        }
        if let cell = cell as? FavouritesListWithCollectionCell {
            cell.selectionDelegate = self
        }
        
        if let cell = cell as? WalletIsReadyCell {
            cell.delegate = self
            return cell
        }
        
        if let cell = cell as? FavoriteContactCell {
            let favToShowCount = favoritesToShow.count
            let name = favoritesToShow[favToShowCount - (itemsArray.count - indexPath.row)].firstName
            cell.configureCell(withName: name, isLast: indexPath.row + 1 == itemsArray.count)
        }
        return cell
    }
    
    
    
    // MARK: TabbarController Delegate
    // TODO:  Think about better place
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard self == viewController else {
            return
        }
        // This is just to force balance update sometimes, but think about better way maybe
        tableView.reloadData()
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

extension MainInfoController: CloseNewWalletNotifDelegate {
    func didClose() {
        itemsArray = [
            "CurrentWalletInfoCell",
            "TransactionHistoryCell",//]
            "FavouritesTitleCell",
            "FavouritesListWithCollectionCell"]
        
        putTransactionsInfoIntoItemsArray()
        tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        
        UserDefaults.standard.set(false, forKey: "isWalletNew")
    }
}


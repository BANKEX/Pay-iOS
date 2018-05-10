//
//  MainInfoController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/4/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

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
    
    var itemsArray = ["TopLogoCell",
                      "CurrentWalletInfoCell",
                      "TransactionHistoryCell"]
//                      "FavouritesTitleCell",
//                      "FavouritesListWithCollectionCell"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        itemsArray = ["TopLogoCell",
                      "CurrentWalletInfoCell",
                      "TransactionHistoryCell",
                      "FavouritesTitleCell",
                      "FavouritesListWithCollectionCell"]
        
        sendEthService = tokensService.selectedERC20Token().address.isEmpty ?
            SendEthServiceImplementation() :
            ERC20TokenContractMethodsServiceImplementation()
        if let firstTwo = sendEthService.getAllTransactions()?.prefix(2) {
            transactionsToShow = Array(firstTwo)
        }
        var arrayOfTransactions = [String]()
        switch transactionsToShow.count {
        case 0:
            arrayOfTransactions = ["EmptyLastTransactionsCell"]
        case 1:
            arrayOfTransactions = ["TopRoundedCell", "LastTransactionHistoryCell","BottomRoundedCell"]

        default:
            arrayOfTransactions = ["TopRoundedCell", "LastTransactionHistoryCell", "TransactionHistoryCell", "BottomRoundedCell"]
        }
        
        let index = itemsArray.index{$0 == "TransactionHistoryCell"} ?? 0
        transactionInitialDiff = index + 2
        itemsArray.insert(contentsOf: arrayOfTransactions, at: index + 1)
        tableView.reloadData()
    }
    
    @IBAction func unwind(segue:UIStoryboardSegue) { }

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
    }
}

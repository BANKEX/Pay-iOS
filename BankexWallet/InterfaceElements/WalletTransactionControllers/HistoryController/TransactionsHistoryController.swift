//
//  TransactionsHistoryController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/4/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class TransactionsHistoryController: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource {
    
    // MARK: empty View
    @IBOutlet weak var emptyViewButton: UIButton!
    @IBOutlet weak var emptyViewLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    
    // MARK: tableView
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: additional items
    @IBOutlet weak var addTransactionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Non-view vars
    var transactionsToShow = [[ETHTransactionModel]]()
    var sections = [String]()
    var presenter: TransactionsHistoryViewOutput!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "DateSectionView", bundle: nil), forHeaderFooterViewReuseIdentifier: "DateSectionView")
        tableView.estimatedSectionHeaderHeight = 32
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
    }
    
    let service: SendEthService = SendEthServiceImplementation()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let objects = service.getAllTransactions()

        guard let obj = objects,
            !obj.isEmpty else {
                // TODO:  technically it's invalid state, but let's check later
                return}
        show(transactions: obj)
    }
    
    // MARK: Update view status
    var canSendTransactions = false
    func showEmptyView() {}
    func showNoKeysAvailableView() { }
    
    func show(transactions: [ETHTransactionModel]) {
        (sections, transactionsToShow) = prepareToShow(transactions: transactions)
        
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        return formatter
    }()
    
    let onlyMonthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
    func prepareToShow(transactions: [ETHTransactionModel]) -> ([String], [[ETHTransactionModel]]) {
        var dictionaryOfTransactionsByDates = [[ETHTransactionModel]]()
        var arrayOfDates = [String]()
        
        transactions.forEach { (nextModel) in
            let modelDate = nextModel.date
            let dateString = modelDate.isInSameYear(date: Date()) ? onlyMonthDateFormatter.string(from: modelDate) : dateFormatter.string(from: modelDate)
            
            if arrayOfDates.contains(dateString) {
                var currentValue = dictionaryOfTransactionsByDates.last ?? [ETHTransactionModel]()
                currentValue.append(nextModel)
                dictionaryOfTransactionsByDates.remove(at: dictionaryOfTransactionsByDates.count - 1)
                dictionaryOfTransactionsByDates.append(currentValue)
                
            } else {
                arrayOfDates.append(dateString)
                dictionaryOfTransactionsByDates.append([nextModel])
            }
        }
        
        return (arrayOfDates, dictionaryOfTransactionsByDates)
    }
    
    // MARK: Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionsToShow[section].count
    }
    
    let identifier = "TransactionHistoryCell"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TransactionHistoryCell
         let transaction = transactionsToShow[indexPath.section][indexPath.row]
        // TODO: Yes, it's a cheat here, but it's faster right now, please change it
        cell.configure(withTransaction: transaction, isLastCell: true)
        return cell
    }
    
    var selectedTransaction: SendEthTransaction?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        guard let transaction = transactionsToShow?[indexPath.row] as? SendEthTransaction else {return}
//        
//        selectedTransaction = transaction
//        performSegue(withIdentifier: "showSendTransactions", sender: self)

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard sections.count > 1 else {
            return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DateSectionView") as! DateSectionView
        view.monthNameLabel.text = sections[section]
        return view
    }
    
    // MARK:
    @objc func showSendEth() {
        performSegue(withIdentifier: "showSendTransactions", sender: self)
    }
    
    @objc func showAddNewKeyController() {
        if canSendTransactions {
            performSegue(withIdentifier: "showSendTransactions", sender: self)
        }
        else {
            performSegue(withIdentifier: "addNewKey", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSendTransactions",
            let transaction = selectedTransaction,
            let navController = segue.destination as? UINavigationController,
            let controller = navController.viewControllers.first as? TokenTransferContainerController {
            controller.selectedTransaction = transaction
            selectedTransaction = nil
        }
    }
}

class DateSectionView: UITableViewHeaderFooterView {
    @IBOutlet weak var monthNameLabel: UILabel!
}

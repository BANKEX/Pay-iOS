//
//  TransactionHistoryViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 30/07/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class TransactionHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let sendEthService: SendEthService = SendEthServiceImplementation()
    
    var transactionsToShow = [[ETHTransactionModel]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showTokensListButtonTapped(_ sender: Any) {
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionsToShow[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionsToShow.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 46))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 22))
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

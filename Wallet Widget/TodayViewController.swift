//
//  TodayViewController.swift
//  Wallet Widget
//
//  Created by Vladislav on 04/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import NotificationCenter


class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var tableView:UITableView!
    
    enum Keys {
        case balance
        case nameWallet
        
        func key() -> String {
            switch self {
            case .balance: return "Balance"
            case .nameWallet: return "Name"
            }
        }
    }
    let fileName = "tokens.json"
    var tokens:[TokenShort]!
    let userDefaults = UserDefaults(suiteName: "group.PayWidget")
    let cellIdentifier = "CurrencyCell"
    var standartHeight:CGFloat = 110
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Storage.isExist(fileName: fileName) {
            tokens = Storage.retrieve(fileName, as: [TokenShort].self)
            tableView.reloadData()
        }
        extensionContext?.widgetLargestAvailableDisplayMode = tokens.isEmpty ? .compact : .expanded
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = standartHeight
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: maxSize.width, height:standartHeight * tokens.count.cgFloat() + standartHeight)
        }else {
            preferredContentSize = maxSize
        }
    }
    
}

extension TodayViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currencyToken = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CurrencyCell
        if indexPath.row == 0 {
            let balance = userDefaults?.string(forKey: Keys.balance.key())
            let name = userDefaults?.string(forKey: Keys.nameWallet.key())
            currencyToken.setData(balance: balance, name: name)
        }else {
            currencyToken.shortToken = tokens[indexPath.row - 1]
        }
        return currencyToken
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            guard let url = URL(string:"pay://ether") else { return }
            extensionContext?.open(url, completionHandler: nil)
        }else {
            guard let url = URL(string:"pay://token.\(tokens[indexPath.row - 1].name)") else { return }
            extensionContext?.open(url, completionHandler: nil)
        }
    }
}

extension Int {
    func cgFloat() -> CGFloat {
        return CGFloat(self)
    }
}


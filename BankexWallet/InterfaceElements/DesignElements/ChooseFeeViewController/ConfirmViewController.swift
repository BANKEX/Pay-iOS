//
//  ConfirmViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 24.06.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ConfirmViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func configureTableView() {
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1))
        tableView.separatorInset.right = 15.0
    }
    


}

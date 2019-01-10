//
//  AutoLockViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 18/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol AutoLockViewControllerDelegate:class {
    func didSelect(_ time:String)
}

class AutoLockViewController:BaseViewController {
    
    @IBOutlet weak var tableView:UITableView!
    
    lazy var arrayTimers: [String] = {
        return Array(Set([5, 10, 15, 20, 25] + [AutoLockService.shared.defaultTime])).sorted().map {"\($0)"}
    }()
    
    let cellIdentifier = "TimerCell"
    
    weak var delegate:AutoLockViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizedStrings.title
        tableView.contentInset.top = 56
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = HeaderView()
        tableView.backgroundColor = UIColor.bgMainColor
        tableView.separatorColor = UIColor.disableColor
    }


}

extension AutoLockViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayTimers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TimerCell
        cell.setData(arrayTimers[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentCell = tableView.cellForRow(at: indexPath) as? TimerCell, let time = currentCell.timerLabel.text else { return }
        delegate?.didSelect(time)
        AutoLockService.shared.saveState(currentCell.timerLabel.text!)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        resetAll()
        return indexPath
    }
    
    
}

private extension AutoLockViewController {
    func resetAll() {
        let cells = tableView.visibleCells as! [TimerCell]
        cells.forEach { $0.doneImage.hide() }
    }
}

private extension AutoLockViewController {
    
    struct LocalizedStrings {
        static let title = NSLocalizedString("Title", tableName: "AppTimeout", comment: "")
    }
}

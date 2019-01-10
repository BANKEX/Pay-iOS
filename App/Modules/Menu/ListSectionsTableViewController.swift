//
//  ListSectionsTableViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 22/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ListSectionsViewController: UIViewController {
    
    @IBOutlet weak var tableView:UITableView!
    
    let cellIdenitifier = "SectionTableCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.register(UINib(nibName: cellIdenitifier, bundle: nil), forCellReuseIdentifier: cellIdenitifier)
        tableView.dataSource = self
        tableView.rowHeight = 56
        tableView.separatorStyle = .none
        selectRow(0)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func selectRow(_ row:Int) {
        chooseRowColorIfNeeded(row)
        tableView(tableView, didSelectRowAt: IndexPath(row: row, section: 0))
    }
    
    func chooseRowColorIfNeeded(_ row:Int) {
        tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
    }
    


}

extension ListSectionsViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nv = storyboard?.instantiateViewController(withIdentifier: "\(indexPath.row)") as! BaseNavigationController
        splitViewController?.showDetailViewController(nv, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdenitifier, for: indexPath) as! SectionTableCell
        cell.section = Section(rawValue: indexPath.row)
        return cell
    }
}

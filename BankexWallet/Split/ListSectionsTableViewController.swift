//
//  ListSectionsTableViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 22/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ListSectionsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 56
        tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nv = storyboard?.instantiateViewController(withIdentifier: "\(indexPath.row)") as! BaseNavigationController
        splitViewController?.showDetailViewController(nv, sender: nil)
    }


}

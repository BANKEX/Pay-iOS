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
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nv = storyboard?.instantiateViewController(withIdentifier: "\(indexPath.row)") as! BaseNavigationController
        splitViewController?.showDetailViewController(nv, sender: nil)
    }


}

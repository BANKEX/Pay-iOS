//
//  WalletInfoViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 17/08/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class WalletInfoViewController: UITableViewController {
    
    var publicAddress: String?
    let walletsService: GlobalWalletsService = HDWalletServiceImplementation()

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
        if section == 0 {
            return view
        } else {
            return view
        }
    }
}

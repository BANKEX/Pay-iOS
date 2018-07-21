//
//  NetworksDelegate.swift
//  BankexWallet
//
//  Created by Vladislav on 22.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

extension NetworksViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let new = listNetworks[indexPath.row]
            networkService.updatePreferredNetwork(customNetwork: new)
            self.delegate?.didTapped(with: new)
        }
    }
}

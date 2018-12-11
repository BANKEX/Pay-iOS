//
//  NetworksDelegate.swift
//  BankexWallet
//
//  Created by Vladislav on 22.07.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit

extension NetworksViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1  {
            let newNet = listNetworks[indexPath.row]
            if (newNet.networkId == 3 || newNet.networkId == 4 || newNet.networkId == 42) && !UserDefaults.standard.bool(forKey: "NotShown") {
                let alertController = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("WarningNetworkSwitch", comment: ""), preferredStyle: .alert)
                alertController.add(title:  NSLocalizedString("Don't show again", comment: "")) {
                    UserDefaults.standard.set(true, forKey: "NotShown")
                    self.networkService.updatePreferredNetwork(customNetwork: newNet)
                    DispatchQueue.main.async {
                        self.delegate?.didTapped(with: newNet)
                    }
                }
                alertController.addOK {
                    self.networkService.updatePreferredNetwork(customNetwork: newNet)
                    DispatchQueue.main.async {
                        self.delegate?.didTapped(with: newNet)
                    }
                }
                present(alertController, animated: true)
                return
            }else {
                networkService.updatePreferredNetwork(customNetwork: newNet)
                DispatchQueue.main.async {
                    self.delegate?.didTapped(with: newNet)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


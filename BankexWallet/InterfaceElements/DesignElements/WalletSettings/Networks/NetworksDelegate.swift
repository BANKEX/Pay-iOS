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
        if indexPath.section == 1  {
            let newNet = listNetworks[indexPath.row]
            if (newNet.networkId == 3 || newNet.networkId == 4 || newNet.networkId == 42) && !UserDefaults.standard.bool(forKey: "NotShown") {
                let alertController = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("WarningNetworkSwitch", comment: ""), preferredStyle: .alert)
                let cancelButton = UIAlertAction(title: NSLocalizedString("Don't show again", comment: ""), style: .cancel) { _ in
                    UserDefaults.standard.set(true, forKey: "NotShown")
                    self.networkService.updatePreferredNetwork(customNetwork: newNet)
                    DispatchQueue.main.async {
                        self.delegate?.didTapped(with: newNet)
                    }
                }
                let okButton = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
                    self.networkService.updatePreferredNetwork(customNetwork: newNet)
                    DispatchQueue.main.async {
                        self.delegate?.didTapped(with: newNet)
                    }
                }
                alertController.addAction(cancelButton)
                alertController.addAction(okButton)
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


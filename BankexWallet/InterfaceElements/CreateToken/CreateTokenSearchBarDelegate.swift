//
//  CreateTokenSearchControllerDelegate.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 30.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

extension CreateTokenController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            
            messageLabel.isHidden = false
            
            view.endEditing(true)
            
            tokensList = nil
            
            tableView.alpha = 0
            tableView.isUserInteractionEnabled = false
            
            tableView.reloadData()
            
        } else {
            
            messageLabel.isHidden = true
            
            tableView.alpha = 1
            tableView.isUserInteractionEnabled = true
            
            let token = searchText
            
            tokensService.getTokensList(with: token, completion: { (result) in
                switch result {
                case .Success(let list):
                    self.tokensAvailability = []
                    self.tokensList = list
                    for _ in 0...list.count-1 {
                        self.tokensAvailability?.append(false)
                    }
                    self.tableView.reloadData()
                    self.updateListForAlreadyAddedTokens()
                case .Error(_):
                    self.tokensList = nil
                }
            })
            
        }
    }
    
    func updateListForAlreadyAddedTokens() {
        let dataQueue = DispatchQueue.global(qos: .background)
        dataQueue.async {
            self.walletData.update(callback: { (etherToken, transactions, availableTokens) in
                if self.tokensList != nil{
                    var i = 0
                    for token in self.tokensList! {
                        for availableToken in availableTokens {
                            if token == availableToken {
                                self.tokensAvailability![i] = true
                                break
                            }
                        }
                        i += 1
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            })
        }
    }
    
}

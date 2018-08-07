//
//  CreateTokenTableViewDelegate.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 30.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

extension CreateTokenController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tokensList != nil {
            return (tokensList?.count)!
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateTokenCell", for: indexPath) as! CreateTokenCell
        let token = tokensList![indexPath.row]
        let available = tokensAvailability![indexPath.row]
        cell.configure(with: token, isAvailable: available)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tokenToAdd = self.tokensList![indexPath.row]
        chosenToken = tokenToAdd
        performSegue(withIdentifier: "addChosenToken", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? TokenInfoController {
            destinationViewController.transitioningDelegate = self
            destinationViewController.token = chosenToken ?? nil
            destinationViewController.interactor = interactor
            destinationViewController.forAdding = true
        }
    }
}

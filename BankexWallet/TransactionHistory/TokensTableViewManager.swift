//
//  TokensTableViewManager.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 02/08/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class TokensTableViewManager: NSObject, UITableViewDataSource, UITableViewDelegate  {
    let tokensService: CustomERC20TokensService = CustomERC20TokensServiceImplementation()

    weak var delegate: ChooseTokenDelegate?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = tokensService.availableTokensList()?.count else { return 0 }
        return count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        guard let tokens = tokensService.availableTokensList() else { return UITableViewCell() }
        cell.textLabel?.text = tokens[indexPath.row].symbol.uppercased()
        cell.textLabel?.textAlignment = UIDevice.isIpad ? .left : .center
        cell.textLabel?.clipsToBounds = true
        cell.clipsToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let tokens = tokensService.availableTokensList() else { return }
        delegate?.didSelectToken(name: tokens[indexPath.row].symbol.uppercased())
    }
    
}


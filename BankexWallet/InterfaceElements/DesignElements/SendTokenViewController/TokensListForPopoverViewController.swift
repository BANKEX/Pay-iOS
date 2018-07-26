//
//  TokensListForPopoverViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 26/07/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class TokensListForPopoverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tokens = [ERC20TokenModel]()
    weak var delegate: ChooseTokenDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.isNavigationBarHidden = true
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tokenCell") as? TokenCell else { return UITableViewCell() }
        cell.configure(name: tokens[indexPath.row].symbol.uppercased())
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectToken(name: tokens[indexPath.row].symbol.uppercased())
    }
}

//tokenCell

class TokenCell: UITableViewCell {
    @IBOutlet weak var tokenNameLabel: UILabel!
    
    func configure(name: String) {
        tokenNameLabel.text = name
    }
    
}

protocol ChooseTokenDelegate: class {
    func didSelectToken(name: String)
}

//
//  TokensListController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 3/15/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class TokensListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    let service: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    var tokens: [ERC20TokenModel]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tokens = service.availableTokensList()
        tableView.reloadData()
    }

    // MARK:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tokens?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokensListCell", for: indexPath) as! TokensListCell
        let token = tokens![indexPath.row]
        cell.configure(with: token)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let token = tokens?[indexPath.row] else {
            return
        }
        let address = token.address
        service.updateSelectedToken(to: address)
        tokens = service.availableTokensList()
        tableView.reloadData()
    }
}

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
    @IBOutlet weak var editButton: UIButton!
    
    private var editEnabled: Bool = false
    
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

    // MARK: Table view methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 0
        } else {
            return (tokens?.count ?? 0)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TokensListCellNew", for: indexPath) as! TokensListCellNew
            let token = tokens![indexPath.row]
            let isSelected = token.address == service.selectedERC20Token().address
            cell.configure(with: token, isSelected: isSelected, isFirstSection: true, isEditing: false)
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TokensListCellNew", for: indexPath) as! TokensListCellNew
            let token = tokens![indexPath.row]
            let isSelected = token.address == service.selectedERC20Token().address
            cell.configure(with: token, isSelected: isSelected, isFirstSection: false, isEditing: editEnabled)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TokensListCellNew", for: indexPath) as! TokensListCellNew
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 116
        } else if indexPath.section == 1 {
            return 53
        } else {
            return 127
        }
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Ethereum"
        } else if section == 1 {
            return "Recent Transactions"
        } else {
            return "Tokens"
        }
    }
    
    @IBAction func editButtonTouched(_ sender: UIButton) {
        editEnabled = !editEnabled
        editButton.setTitle(editEnabled ? "Cancel" : "Edit", for: .normal)
        tableView.reloadData()
    }
    
    
}

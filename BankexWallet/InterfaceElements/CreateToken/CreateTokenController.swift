//
//  CreateTokenController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 3/15/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class CreateTokenController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var messageLabel: UILabel!
    
    let tokensService: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    var tokensList: [ERC20TokenModel]?
    var tokensAvailability: [Bool]?
    var walletData = WalletData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        self.hideKeyboardWhenTappedAround()
        self.setupViewResizerOnKeyboardShown()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        tableView.alpha = 0
        tableView.isUserInteractionEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "Add New Token"
    }
    
}

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
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

extension CreateTokenController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            
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
            
            let tokenAddress = searchBar.text
            
            tokensService.getTokensList(with: tokenAddress!, completion: { (result) in
                switch result {
                case .Success(let list):
                    self.tokensAvailability = []
                    self.tokensList = list
                    for i in 0...list.count-1 {
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

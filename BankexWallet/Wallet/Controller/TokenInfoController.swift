//
//  TokenInfoController.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 23.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class TokenInfoController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addingButton: UIButton!
    
    let keysService: SingleKeyService  = SingleKeyServiceImplementation()
    let tokensService: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    var token: ERC20TokenModel?
    
    
    var forAdding: Bool = false
    
    
    override func viewDidLoad() {
        setTableView()
//        if token == nil && keysService.selectedWallet()?.name == nil {
//            tokensService.getNewConversion(for: (token?.symbol.uppercased())!)
//        }
        if !forAdding {
            addingButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    fileprivate func setTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: TokenInfoCell.identifier, bundle: nil), forCellReuseIdentifier: TokenInfoCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TokenInfoCell.identifier) as! TokenInfoCell
        guard token != nil else {return cell}
        switch indexPath.row {
        case TokenInfoRaws.address.rawValue :
            cell.selectedIndex = TokenInfoRaws.address.rawValue
        case TokenInfoRaws.currency.rawValue :
            cell.selectedIndex = TokenInfoRaws.currency.rawValue
        case TokenInfoRaws.decimals.rawValue :
            cell.selectedIndex = TokenInfoRaws.decimals.rawValue
        default:
            break
        }
        cell.selectedToken = self.token
        return cell
        
    }
    
    @IBAction func addTokenAction(_ sender: UIButton) {
        guard let foundModel = token else {
            return
        }
        tokensService.addNewCustomToken(with: foundModel.address,
                                        name: foundModel.name,
                                        decimals: foundModel.decimals,
                                        symbol: foundModel.symbol)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
}

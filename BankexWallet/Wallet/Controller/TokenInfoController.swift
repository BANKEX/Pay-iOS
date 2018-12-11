//
//  TokenInfoController.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 23.07.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit
import web3swift
import Amplitude_iOS

protocol TokenInfoControllerDelegate:class {
    func didAddToken()
}

class TokenInfoController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addingButton: UIButton!
    
    let keysService: SingleKeyService  = SingleKeyServiceImplementation()
    let tokensService: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    var token: ERC20TokenModel?
    let utilsService = CustomTokenUtilsServiceImplementation()
    
    
    var forAdding: Bool = false
    
    weak var delegate:TokenInfoControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("AddNewToken", comment: "")
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
        
        Amplitude.instance().logEvent("Token Created")
        
        delegate?.didAddToken()
        handleToken(foundModel)
    }
    
    func handleToken(_ token:ERC20TokenModel) {
        guard let adddedTokens = tokensService.availableTokensList()?.count else { return }
        updateBalance(token) { (balance) in
            let shortToken = TokenShort(name: token.name, balance: balance!)
            if (adddedTokens - 1) <= 2 {
                if !TokenShortService.arrayTokensShort.contains(shortToken) {
                    TokenShortService.arrayTokensShort.append(shortToken)
                    TokenShortService.arrayTokensShort.sort { Double($0.balance)! > Double($1.balance)! }
                    Storage.store(Array(TokenShortService.arrayTokensShort.prefix(2)), as: "tokens.json")
                }
            }else {
                let secondToken = TokenShortService.arrayTokensShort.last!
                let firstToken = TokenShortService.arrayTokensShort.first!
                if Double(secondToken.balance)! < Double(balance!)! {
                    if Double(firstToken.balance)! > Double(balance!)! {
                        TokenShortService.arrayTokensShort[1] = shortToken
                    }else {
                        TokenShortService.arrayTokensShort[0] = shortToken
                    }
                    Storage.store(Array(TokenShortService.arrayTokensShort.prefix(2)), as: "tokens.json")
                }
            }
        }
    }
    
    
    func updateBalance(_ token:ERC20TokenModel,_ onComplition:@escaping ((String)?)->()) {
        utilsService.getBalance(for: token.address, address: keysService.selectedAddress() ?? "") { (result) in
            
            switch result {
            case .Success(let response):
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                let formattedAmount = Web3.Utils.formatToEthereumUnits(response,
                                                                       toUnits: .eth,
                                                                       decimals: 8)
                onComplition(formattedAmount!)
            case .Error( _):
                onComplition(nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 || indexPath.row == 2 {
            return 80.0
        }
        return 90.0
    }
    
}

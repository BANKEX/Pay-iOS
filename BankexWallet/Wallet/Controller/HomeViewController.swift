//
//  HomeViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 11.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import SkeletonView

class HomeViewController: BaseViewController {
    
    
    enum HomeSections:Int {
        case Ethereum = 0, Tokens
    }
    
    @IBOutlet weak var tableView:UITableView!

    
    
    let keyService = SingleKeyServiceImplementation()
    let tokenSerive = CustomERC20TokensServiceImplementation()
    let service: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    let conversionService = FiatServiceImplementation.service
    var etherToken: ERC20TokenModel?
    var tokens = [ERC20TokenModel]()
    let walletData = WalletData()
    var selectedToken:ERC20TokenModel!
    lazy var ethHeader:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Ethereum"
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.textColor = .black
        return label
    }()
    lazy var tokensHeader:UILabel = {
        let label = UILabel()
        //My favorite magic number
        label.textAlignment = .left
        label.text = "Tokens"
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.textColor = .black
        return label
    }()
    lazy var addTokenBtn:BaseButton = {
        let button = BaseButton()
        let widthBtn:CGFloat = 80.0
        button.frame = CGRect(x: tableView.bounds.width - widthBtn, y: 90.0 - 22.0, width: widthBtn, height: 22.0)
        button.setTitle("Add Tokens", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.addTarget(self, action: #selector(self.createToken), for: .touchUpInside)
        button.setTitleColor(WalletColors.mainColor, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    
    //LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupStatusBarColor()
        updateTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let walletInfoVC = segue.destination as? MainInfoController {
            walletInfoVC.selectedToken = selectedToken
        }
    }

    
    
    //IBAction
    
    @IBAction func createToken() {
        performSegue(withIdentifier: "createToken", sender: nil)
    }
    
    
    //Methods
    fileprivate func setupStatusBarColor() {
        UIApplication.shared.statusBarView?.backgroundColor = .white
    }
    
    
     fileprivate func updateTableView() {
        view.showSkeleton()
        let dataQueue = DispatchQueue.global(qos: .userInitiated)
        dataQueue.async {
            self.walletData.update(callback: { (etherToken, transactions, availableTokens) in
                DispatchQueue.main.async {
                    self.tokens = availableTokens
                    self.tableView.reloadData()
                    self.view.stopSkeletonAnimation()
                    self.view.hideSkeleton()
                }
                
            })
        }
    }
    
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(UINib(nibName: WalletTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: WalletTableViewCell.identifier)
        tableView.register(UINib(nibName: TokenTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TokenTableViewCell.identifier)
        tableView.register(UINib(nibName: PlaceholderCell.identifier, bundle: nil), forCellReuseIdentifier: PlaceholderCell.identifier)
        tableView.register(UINib(nibName: EmptyTableCell.identifier, bundle: nil), forCellReuseIdentifier: EmptyTableCell.identifier)
        tableView.isSkeletonable = true
    }

}

extension HomeViewController: UITableViewDataSource,SkeletonTableViewDataSource,UITableViewDelegate {
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return TokenTableViewCell.identifier
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == HomeSections.Ethereum.rawValue {
            return 1
        }else {
            if tokens.isEmpty {
                return 1
            }
            return tokens.count == 1 ? 3 : tokens.count * 2 + 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 70.0
        }else {
            if tokens.isEmpty {
                return 180.0
            }
            return indexPath.row % 2 == 0 ? 20.0 : 70.0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if HomeSections.Ethereum.rawValue == indexPath.section {
            if let walletCell = tableView.dequeueReusableCell(withIdentifier: WalletTableViewCell.identifier, for: indexPath) as? WalletTableViewCell {
                let selectedWallet = keyService.selectedWallet()
                walletCell.wallet = selectedWallet
                walletCell.token = tokenSerive.selectedERC20Token()
                return walletCell
            }
        }else if HomeSections.Tokens.rawValue == 1 {
            if tokens.isEmpty {
                let emptyCell = tableView.dequeueReusableCell(withIdentifier: EmptyTableCell.identifier, for: indexPath) as! EmptyTableCell
                return emptyCell
            }
            if indexPath.row % 2 == 0 {
                if let placeholderCell = tableView.dequeueReusableCell(withIdentifier: PlaceholderCell.identifier, for: indexPath) as? PlaceholderCell {
                    return placeholderCell
                }
            }else {
                if let tokenCell = tableView.dequeueReusableCell(withIdentifier: TokenTableViewCell.identifier, for: indexPath) as? TokenTableViewCell {
                    let num = floor(Double(indexPath.row/2))
                    tokenCell.token = tokens[Int(num)]
                    tokenCell.isSearchable = false
                    return tokenCell
                }
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == HomeSections.Ethereum.rawValue {
            let ethView = UIView()
            ethView.backgroundColor = WalletColors.bgMainColor
            ethHeader.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 22.0)
            ethView.addSubview(ethHeader)
            return ethView
        }else if section == HomeSections.Tokens.rawValue {
            let tokensView = UIView()
            tokensView.backgroundColor = WalletColors.bgMainColor
            tokensHeader.frame = CGRect(x: 0, y: 90.0 - 22.0, width: tableView.bounds.width/2, height: 22.0)
            tokensView.addSubview(tokensHeader)
            tokensView.addSubview(addTokenBtn)
            return tokensView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HomeSections.Ethereum.rawValue == section ? 52.0 : 90.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if HomeSections.Ethereum.rawValue == indexPath.section {
            selectedToken = tokenSerive.selectedERC20Token()
        }else {
            let num = floor(Double(indexPath.row/2))
            selectedToken = tokens[Int(num)]
        }
        performSegue(withIdentifier: "walletInfo", sender: nil)
    }
   
    
}



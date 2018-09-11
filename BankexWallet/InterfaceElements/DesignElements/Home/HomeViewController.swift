//
//  HomeViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 11.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    
    enum HomeSections:Int {
        case Ethereum = 0, Tokens
    }
    
    @IBOutlet weak var tableView:UITableView!

    
    
    let itemsArray = ["EthereumHeaderCell","EthereumTableVIewCell","TokensHeaderTableCell","TokenTableViewCell","EmptyTokensTableCell"]
    let keyService = SingleKeyServiceImplementation()
    let tokenSerive = CustomERC20TokensServiceImplementation()
    let service: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    let conversionService = FiatServiceImplementation.service
    var etherToken: ERC20TokenModel?
    var tokens = [ERC20TokenModel]()
    
    
    //LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupStatusBarColor()
    }
    
    
    
    
    //Methods
    fileprivate func setupStatusBarColor() {
        UIApplication.shared.statusBarView?.backgroundColor = .white
    }
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(UINib(nibName: itemsArray[0], bundle: nil), forCellReuseIdentifier: itemsArray[0])
        tableView.register(UINib(nibName: itemsArray[1], bundle: nil), forCellReuseIdentifier: itemsArray[1])
        tableView.register(UINib(nibName: itemsArray[2], bundle: nil), forCellReuseIdentifier: itemsArray[2])
        tableView.register(UINib(nibName: itemsArray[3], bundle: nil), forCellReuseIdentifier: itemsArray[3])
        tableView.register(UINib(nibName: itemsArray[4], bundle: nil), forCellReuseIdentifier: itemsArray[4])
    }

}

extension HomeViewController: UITableViewDataSource,UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0: return 54.0
        case 1: return 70.0
        case 2: return 90.0
        case 3: return 200.0
        default: return 44.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 0 {
            if let ethHeaderCell = tableView.dequeueReusableCell(withIdentifier: itemsArray[0], for: indexPath) as? EthereumHeaderCell {
                return ethHeaderCell
            }
        }else if row == 1 {
            if let ethCell = tableView.dequeueReusableCell(withIdentifier: itemsArray[1], for: indexPath) as? EthereumTableVIewCell {
                return ethCell
            }
        }else if row == 2 {
            if let tokenHeaderCell = tableView.dequeueReusableCell(withIdentifier: itemsArray[2], for: indexPath) as? TokensHeaderTableCell {
                return tokenHeaderCell
            }
        }else if row == 3 {
            if tokens.isEmpty {
                if let emptyTokenCell = tableView.dequeueReusableCell(withIdentifier: itemsArray[4], for: indexPath) as? EmptyTokensTableCell {
                    return emptyTokenCell
                }
            }else {
                //Return list tokens
                
            }
        }
        return UITableViewCell()
    }
   
    
}



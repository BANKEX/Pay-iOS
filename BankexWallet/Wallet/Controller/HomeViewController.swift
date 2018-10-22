//
//  HomeViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 11.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import SkeletonView

struct TokenShortService {
    static var arrayTokensShort:[TokenShort] = []
}

class HomeViewController: BaseViewController {
    
    enum State {
        case home,fromContact
    }
    
    enum HomeSections:Int {
        case Ethereum = 0, Tokens
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainSign: UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIView!
    //Delete tabbar
    var state:State = .home {
        didSet {
            if state == .home {
                navigationController?.setNavigationBarHidden(true, animated: true)
                mainSign.isHidden = false
                topConstraint.constant = 0
            } else {
                navigationController?.setNavigationBarHidden(false, animated: true)
                mainSign.isHidden = true
                navigationItem.title = NSLocalizedString("SendFunds", comment: "")
                topConstraint.constant = -(inset-40)
               let backButton = self.customBackButton()
                backButton.addTarget(self, action: #selector(self.back), for: .touchUpInside)
                navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
            }
        }
    }
    
    
    
    
    var inset:CGFloat {
        return imageView.bounds.size.height - 20.0
    }
    var isFromContact:Bool = false
    var addressFromContract:String?
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
        if UIDevice.isIpad {
            button.frame = CGRect(x: tableView.bounds.width - widthBtn - 50.0, y: 65.0 - 22.0, width: widthBtn, height: 22.0)
        }else {
            button.frame = CGRect(x: tableView.bounds.width - widthBtn - 15.0, y: 65.0 - 22.0, width: widthBtn, height: 22.0)
        }
        button.setTitle(NSLocalizedString("AddTokens", comment:""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.addTarget(self, action: #selector(self.createToken), for: .touchUpInside)
        button.setTitleColor(UIColor.mainColor, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    
    //LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        if Guide.value != nil {
            let addrVC = storyboard?.instantiateViewController(withIdentifier: "AddressQRCodeController") as! AddressQRCodeController
            addrVC.addressToGenerateQR = SingleKeyServiceImplementation().selectedAddress()!
            navigationController?.pushViewController(addrVC, animated: false)
        }
        setupTableView()
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeWallet.notificationName(), object: nil, queue: nil) { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catchUserActivity()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageView.shimmerAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let sortedArray = TokenShortService.arrayTokensShort.sorted { lhs, rhs -> Bool in
                return Double(lhs.balance)! > Double(rhs.balance)!
            }
            Storage.store(Array(sortedArray.prefix(2)), as: "tokens.json")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TokenShortService.arrayTokensShort.removeAll()
        setupStatusBarColor()
        state = isFromContact ? .fromContact : .home
        updateTableView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Guide.value = nil
    }

    
    
    //IBAction
    
    @IBAction func createToken() {
        performSegue(withIdentifier: "createToken", sender: nil)
    }
    
    @IBAction func back() {
        navigationController?.popViewController(animated: true)
        isFromContact = false
        Mediator.contactAddr = nil
    }
    
    //Methods
    fileprivate func setupStatusBarColor() {
        UIApplication.shared.statusBarView?.backgroundColor = .white
        UIApplication.shared.statusBarStyle = .default
    }
    
    func catchUserActivity() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let selectedContact = appDelegate.selectedContact {
            tabBarController?.selectedIndex = 2
            let navVC = tabBarController?.viewControllers![2] as? BaseNavigationController
            navVC?.popToRootViewController(animated: false)
            let listVC = navVC?.viewControllers.first as? ListContactsViewController
            listVC?.chooseContact(contact: selectedContact)
        }
    }
    
    
     fileprivate func updateTableView() {
        view.showSkeleton()
        let dataQueue = DispatchQueue.global(qos: .userInitiated)
        dataQueue.async {
            self.walletData.update(callback: { (etherToken, transactions, availableTokens) in
                DispatchQueue.main.async {
                    self.etherToken = etherToken
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
            ethView.backgroundColor = .clear
            if UIDevice.isIpad {
               ethHeader.frame = CGRect(x: 52, y: 0, width: tableView.bounds.width, height: 22.0)
            }else {
                ethHeader.frame = CGRect(x: 15, y: 0, width: tableView.bounds.width, height: 22.0)
            }
            ethView.addSubview(ethHeader)
            return ethView
        }else if section == HomeSections.Tokens.rawValue {
            let tokensView = UIView()
            tokensView.backgroundColor = .clear
            if UIDevice.isIpad {
                tokensHeader.frame = CGRect(x: 52, y: 65.0 - 22.0, width: tableView.bounds.width/2, height: 22.0)
            }else {
                tokensHeader.frame = CGRect(x: 15, y: 65.0 - 22.0, width: tableView.bounds.width/2, height: 22.0)
            }
            tokensView.addSubview(tokensHeader)
            tokensView.addSubview(addTokenBtn)
            return tokensView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HomeSections.Ethereum.rawValue == section ? 52.0 : 65.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if isFromContact && !tokens.isEmpty {
                let sendToken = storyboard?.instantiateViewController(withIdentifier: "SendTokenViewController") as! SendTokenViewController
                navigationController?.pushViewController(sendToken, animated: true)
                performSegue(withIdentifier: "walletInfo", sender: nil)
                return
            }
            if HomeSections.Ethereum.rawValue == indexPath.section {
                tokenSerive.updateSelectedToken(to: etherToken!.address, completion: nil)
                performSegue(withIdentifier: "walletInfo", sender: nil)
            }else if HomeSections.Tokens.rawValue == indexPath.section && !tokens.isEmpty {
                let num = floor(Double(indexPath.row/2))
                selectedToken = tokens[Int(num)]
                tokenSerive.updateSelectedToken(to: selectedToken.address, completion: nil)
                performSegue(withIdentifier: "walletInfo", sender: nil)
            }
    }
    
}


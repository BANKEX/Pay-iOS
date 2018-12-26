//
//  HomeViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 11.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import Amplitude_iOS
import MessageUI

struct TokenShortService {
    static var arrayTokensShort:[TokenShort] = []
}

class HomeViewController: BaseViewController {
    
    enum State {
        case home,fromContact
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
    
    private struct ViewModel {
        
        struct Section {
            let headerView: UIView?
            let rows: [Row]
        }
        
        enum Row {
            case wallet
            case empty
            case placeholder
            case token(token: ERC20TokenModel)
        }
        
        let sections: [Section]
    }
    
    private var viewModel = ViewModel(sections: [])
    
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
    let walletData = WalletData()
    var selectedToken:ERC20TokenModel!
    
    @IBOutlet var assetManagementHeaderView: UIView!
    
    lazy var walletHeaderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Ethereum"
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.textColor = .black
        
        return label
    }()
    
    lazy var walletHeaderView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        headerView.addSubview(walletHeaderLabel)
        headerView.frame.size.height = 52
        
        return headerView
    }()
    
    lazy var utilityTokensHeaderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Tokens"
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.textColor = .black
        
        return label
    }()
    
    lazy var utilityTokensHeaderView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        headerView.addSubview(utilityTokensHeaderLabel)
        headerView.frame.size.height = 65
        
        return headerView
    }()
    
    lazy var securityTokensHeaderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Security Tokens"
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.textColor = .black
        
        return label
    }()
    
    lazy var securityTokensHeaderView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        headerView.addSubview(securityTokensHeaderLabel)
        headerView.frame.size.height = 65
        
        return headerView
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
        //imageView.shimmerAnimation()
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
    
    @IBAction func openAssetManagementPage() {
        Amplitude.instance()?.logEvent("Asset Management Learn More Opened")
        
        performSegue(withIdentifier: "AssetManagementPage", sender: self)
    }
    
    @IBAction func showAssetManagementContacts() {
        performSegue(withIdentifier: "AssetManagementContacts", sender: self)
    }
    
    @IBAction func __disabled_feature_showPerformEthTransfer() {
        Amplitude.instance()?.logEvent("Asset Management ETH Screen Opened")
        
        performSegue(withIdentifier: "AssetManagementEth", sender: self)
    }
    
    @IBAction func __disabled_feature_showPerformBtcTransfer() {
        Amplitude.instance()?.logEvent("Asset Management BTC Screen Opened")
        
        performSegue(withIdentifier: "AssetManagementBtc", sender: self)
    }
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {}
    
    //Methods
    fileprivate func setupStatusBarColor() {
        UIApplication.shared.statusBarView?.backgroundColor = .white
        UIApplication.shared.statusBarStyle = .default
    }
    
    func catchUserActivity() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let selectedContact = appDelegate.selectedContact {
            appDelegate.selectedContact = nil
            if UIDevice.isIpad {
                let listContactsVC = CreateVC(byName: "ListContactsViewController") as! ListContactsViewController
                let nav = BaseNavigationController(rootViewController: listContactsVC)
                let profileVC = CreateVC(byName: "ProfileContactViewController") as! ProfileContactViewController
                profileVC.selectedContact = selectedContact
                nav.pushViewController(profileVC, animated: false)
                splitViewController?.showDetailViewController(nav, sender: nil)
                return
            }
            tabBarController?.selectedIndex = 2
            let navVC = tabBarController?.viewControllers![2] as? BaseNavigationController
            navVC?.popToRootViewController(animated: false)
            let listVC = navVC?.viewControllers.first as? ListContactsViewController
            listVC?.chooseContact(contact: selectedContact)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIDevice.isIpad {
            walletHeaderLabel.frame = CGRect(x: 52, y: 52.0 - 22.0, width: tableView.bounds.width, height: 22.0)
        }else {
            walletHeaderLabel.frame = CGRect(x: 15, y: 52.0 - 22.0, width: tableView.bounds.width, height: 22.0)
        }
        
        if UIDevice.isIpad {
            utilityTokensHeaderLabel.frame = CGRect(x: 52, y: 65.0 - 22.0, width: tableView.bounds.width/2, height: 22.0)
        }else {
            utilityTokensHeaderLabel.frame = CGRect(x: 15, y: 65.0 - 22.0, width: tableView.bounds.width/2, height: 22.0)
        }
        
        if UIDevice.isIpad {
            securityTokensHeaderLabel.frame = CGRect(x: 52, y: 65.0 - 22.0, width: tableView.bounds.width/2, height: 22.0)
        }else {
            securityTokensHeaderLabel.frame = CGRect(x: 15, y: 65.0 - 22.0, width: tableView.bounds.width/2, height: 22.0)
        }
    }
    
    
     fileprivate func updateTableView() {
        let dataQueue = DispatchQueue.global(qos: .userInitiated)
        dataQueue.async {
            self.walletData.update(callback: { (etherToken, transactions, availableTokens) in
                DispatchQueue.main.async {
                    self.updateViewModel(with: availableTokens)
                    
                    self.etherToken = etherToken
                    self.tableView.reloadData()
                }
                
            })
        }
    }
    
    fileprivate func updateViewModel(with availableTokens: [ERC20TokenModel]) {
        let utilityTokens = availableTokens.filter { $0.isSecurity == false }
        let securityTokens = availableTokens.filter { $0.isSecurity == true }
        
        var sections: [ViewModel.Section] = []
        
        let assetManagementSection = ViewModel.Section(headerView: assetManagementHeaderView, rows: [])
        sections.append(assetManagementSection)
        
        let walletSection = ViewModel.Section(headerView: walletHeaderView, rows: [.placeholder, .wallet])
        sections.append(walletSection)
        
        var addTokenButtonUsed = false
        
        if utilityTokens.count > 0 {
            if addTokenButtonUsed == false {
                addTokenButtonUsed = true
                utilityTokensHeaderView.addSubview(addTokenBtn)
            }
            
            let section = ViewModel.Section(headerView: utilityTokensHeaderView, rows: rows(for: utilityTokens))
            
            sections.append(section)
        }
        
        if securityTokens.count > 0 {
            if addTokenButtonUsed == false {
                addTokenButtonUsed = true
                securityTokensHeaderView.addSubview(addTokenBtn)
            }
            
            let section = ViewModel.Section(headerView: securityTokensHeaderView, rows: rows(for: securityTokens))
            
            sections.append(section)
        }
        
        if utilityTokens.count == 0 && securityTokens.count == 0 {
            if addTokenButtonUsed == false {
                addTokenButtonUsed = true
                utilityTokensHeaderView.addSubview(addTokenBtn)
            }
            
            let section = ViewModel.Section(headerView: utilityTokensHeaderView, rows: [.empty])
            
            sections.append(section)
        }
        
        viewModel = ViewModel(sections: sections)
    }
    
    private func rows(for tokens: [ERC20TokenModel]) -> [ViewModel.Row] {
        return tokens.reduce([], { (rows, token) -> [ViewModel.Row] in
            let tokenRows: [ViewModel.Row] = [.placeholder, .token(token: token)]
            
            return rows + tokenRows
        })
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
    }

}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = viewModel.sections[indexPath.section].rows[indexPath.row]
        
        switch row {
        case .empty: return 180
        case .placeholder: return 20
        case .token: return 70
        case .wallet: return 70
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = viewModel.sections[indexPath.section].rows[indexPath.row]
        
        switch row {
        case .empty: return tableView.dequeueReusableCell(withIdentifier: EmptyTableCell.identifier, for: indexPath)
        case .placeholder: return tableView.dequeueReusableCell(withIdentifier: PlaceholderCell.identifier, for: indexPath)
        case .wallet: return tableView.dequeueReusableCell(withIdentifier: WalletTableViewCell.identifier, for: indexPath)
        case .token(let token):
            let tokenCell = tableView.dequeueReusableCell(withIdentifier: TokenTableViewCell.identifier, for: indexPath) as! TokenTableViewCell
            tokenCell.token = token
            tokenCell.isSearchable = false
            
            return tokenCell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewModel.sections[section].headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.sections[section].headerView?.frame.size.height ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = viewModel.sections[indexPath.section].rows[indexPath.row]
        
        switch row {
        case .empty: return
        case .placeholder: return
        case .wallet:
            tokenSerive.updateSelectedToken(to: etherToken!.address) { [weak self] in
                guard let controller = self else { return }

                if controller.isFromContact {
                    let sendToken = CreateVC(byName: "SendTokenViewController") as! SendTokenViewController
                    controller.navigationController?.pushViewController(sendToken, animated: true)
                    
                } else {
                    controller.performSegue(withIdentifier: "walletInfo", sender: nil)
                }
            }
        case .token(let token):
            selectedToken = token
            tokenSerive.updateSelectedToken(to: selectedToken.address) { [weak self] in
                guard let controller = self else { return }
                
                if controller.isFromContact {
                    let sendToken = CreateVC(byName: "SendTokenViewController") as! SendTokenViewController
                    controller.navigationController?.pushViewController(sendToken, animated: true)
                    
                } else {
                    controller.performSegue(withIdentifier: "walletInfo", sender: nil)
                }
            }
        }
    }
    
}

extension HomeViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            let navigationController = segue.destination as? UINavigationController,
            ["AssetManagementContacts", "AssetManagementEth", "AssetManagementBtc", "AssetManagementPage"].contains(segue.identifier ?? "")
        {
            UIApplication.shared.statusBarView?.backgroundColor = UIColor.mainColor
            UIApplication.shared.statusBarStyle = .lightContent
            
            navigationController.navigationBar.barTintColor = UIColor.mainColor
            navigationController.navigationBar.tintColor = UIColor.white
            navigationController.navigationBar.isTranslucent = false
            navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationController.navigationBar.shadowImage = UIImage()
        }
        
        if
            segue.identifier == "AssetManagementPage",
            let navigationController = segue.destination as? UINavigationController,
            let viewController = navigationController.viewControllers.first as? AssetManagementBrowserViewController
        {
            viewController.link = URL(string: "https://bankex.com/en/sto/asset-management")!
            viewController.showDismissButton = true
        }
    }
    
}

extension HomeViewController: MFMailComposeViewControllerDelegate {
    
    private func sendAssetManagementRequestEmail(for token: String) {
        let mailComposeViewController: MFMailComposeViewController? = MFMailComposeViewController()
        
        guard let viewController = mailComposeViewController else { return }
        
        let subject = "Request \(token) Asset management"
        let message = "Request Asset management"
        
        viewController.mailComposeDelegate = self
        viewController.setToRecipients(["sales@bankex.com"])
        viewController.setSubject(subject)
        viewController.setMessageBody(message, isHTML: false)
        
        present(viewController, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showPerformEthTransfer() {
        Amplitude.instance()?.logEvent("Asset Management ETH Email Opened")
        
        sendAssetManagementRequestEmail(for: "ETH")
    }
    
    @IBAction func showPerformBtcTransfer() {
        Amplitude.instance()?.logEvent("Asset Management BTC Email Opened")
        
        sendAssetManagementRequestEmail(for: "BTC")
    }
    
}


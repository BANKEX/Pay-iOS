//
//  CreateTokenController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 3/15/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class CreateTokenController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bottomContraint:NSLayoutConstraint!
    @IBOutlet weak var pasteButton:UIButton!
    @IBOutlet weak var qrButton:UIButton!
    @IBOutlet weak var addTokenLbl:UILabel!
    
    var needAddTokenAnimation = false
    
    var chosenToken: ERC20TokenModel?
    
    let tokensService: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    var tokensList: [ERC20TokenModel]?
    var tokensAvailability: [Bool]?
    var walletData = WalletData()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = WalletColors.bgMainColor
        setupNavBar()
        setupTableView()
        setupQRBtn()
        setupPasteButton()
        self.hideKeyboardWhenTappedAround()
        //self.setupViewResizerOnKeyboardShown()
        searchBar.delegate = self
        bottomContraint.constant = -58.0
    }
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = WalletColors.bgMainColor
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alpha = 0
        tableView.showsVerticalScrollIndicator = false
        tableView.isUserInteractionEnabled = false
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: TokenTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TokenTableViewCell.identifier)
        tableView.register(UINib(nibName: PlaceholderCell.identifier, bundle: nil), forCellReuseIdentifier: PlaceholderCell.identifier)
    }
    
    
    fileprivate func setupNavBar() {
        navigationController?.navigationBar.topItem?.title = NSLocalizedString("Wallet", comment: "")
        self.title = NSLocalizedString("Add new token", comment: "")
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let searchText = searchBar.text else {
            return
        }
        DispatchQueue.main.async {
            if self.needAddTokenAnimation {
                self.addTokenLbl.text = "Token was added to your wallet"
                self.needAddTokenAnimation = false
                UIView.animate(withDuration: 0.6,animations: {
                    if #available(iOS 11.0, *) {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let bottomInset = appDelegate.window?.safeAreaInsets.bottom
                        self.bottomContraint.constant = bottomInset!
                    }else {
                        self.bottomContraint.constant = 0
                    }
                    self.view.layoutIfNeeded()
                }) { (_) in
                    UIView.animate(withDuration: 0.7,delay:0.5,animations: {
                        self.bottomContraint.constant = -58.0
                        self.view.layoutIfNeeded()
                    })
                }
            }
            
            self.searchBar(self.searchBar, textDidChange: searchText)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? TokenInfoController {
            destinationViewController.token = chosenToken ?? nil
            destinationViewController.forAdding = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    
    @IBAction func textFromBuffer(_ sender:Any) {
        if let string = UIPasteboard.general.string  {
            searchBar.text = string
            DispatchQueue.main.async {
                self.searchBar(self.searchBar, textDidChange: string)
            }
        }
    }
    
    @IBAction func unwindFromAddVC(_ sender: UIStoryboardSegue) {
        if sender.source is TokenInfoController {
            self.needAddTokenAnimation = true
        }
    }
    
    @IBAction func scanTapped() {
        let qrReader = QRReaderVC()
        qrReader.delegate = self
        present(qrReader, animated: true)
    }
    
    
    fileprivate func setupPasteButton() {
        pasteButton.layer.borderColor = WalletColors.mainColor.cgColor
        pasteButton.layer.borderWidth = 2.0
        pasteButton.layer.cornerRadius = 8.0
        pasteButton.setTitle(NSLocalizedString("Paste", comment: ""), for: .normal)
        pasteButton.setTitleColor(WalletColors.mainColor, for: .normal)
    }
    
    fileprivate func setupQRBtn() {
        qrButton.layer.borderColor = WalletColors.mainColor.cgColor
        qrButton.layer.borderWidth = 2.0
        qrButton.layer.cornerRadius = 8.0
    }
    
    
}


extension CreateTokenController: QRReaderVCDelegate {
    func didScan(_ result: String) {
        var str:String
        if let parsed = Web3.EIP67CodeParser.parse(result) {
            str = parsed.address.address
        }else {
            str = result
        }
        searchBar.text = str
        searchBar.becomeFirstResponder()
    }
}

extension CreateTokenController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tokensList != nil {
            return ((tokensList?.count)! * 2) + 1
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row % 2 == 0 ? 20.0 : 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let placeholderCell = tableView.dequeueReusableCell(withIdentifier: PlaceholderCell.identifier, for: indexPath) as! PlaceholderCell
            return placeholderCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: TokenTableViewCell.identifier, for: indexPath) as! TokenTableViewCell
        let num = floor(Double(indexPath.row/2))
        let token = tokensList![Int(num)]
        //        let available = tokensAvailability![indexPath.row]
        //        cell.configure(with: token, isAvailable: available)
        cell.token = token
        cell.isSearchable = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let num = floor(Double(indexPath.row/2))
        let tokenToAdd = self.tokensList![Int(num)]
        if tokenToAdd.isAdded {
            addTokenLbl.text = "Token is already added to your wallet"
            UIView.animate(withDuration: 0.6,animations: {
                if #available(iOS 11.0, *) {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let bottomInset = appDelegate.window?.safeAreaInsets.bottom
                    self.bottomContraint.constant = bottomInset!
                }else {
                    self.bottomContraint.constant = 0
                }
                self.view.layoutIfNeeded()
            }) { (_) in
                UIView.animate(withDuration: 0.7,delay:0.5,animations: {
                    self.bottomContraint.constant = -58.0
                    self.view.layoutIfNeeded()
                })
            }
            return
        }
        chosenToken = tokenToAdd
        performSegue(withIdentifier: "addChosenToken", sender: self)
    }
}



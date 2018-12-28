//
//  CreateTokenController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 3/15/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift
import AVFoundation

class CreateTokenController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bottomContraint:NSLayoutConstraint!
    @IBOutlet weak var pasteButton:PasteButton!
    @IBOutlet weak var qrButton:QRButton!
    @IBOutlet weak var addTokenLbl:UILabel!
    
    var needAddTokenAnimation = false
    
    var chosenToken: ERC20TokenModel?
    var isAnimating = false
    let tokensService: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    var tokensList: [ERC20TokenModel]?
    var tokensAvailability: [Bool]?
    var walletData = WalletData()
    lazy var supportView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.QRReader.successColor
        return view
    }()
    lazy var supportLbl:UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textAlignment = .center
        return label
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.bgMainColor
        setupNavBar()
        setupTableView()
        setupSupportView()
        self.hideKeyboardWhenTappedAround()
        //self.setupViewResizerOnKeyboardShown()
        searchBar.delegate = self
    }
    
    private func setupSupportView() {
        supportView.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 58.0)
        supportLbl.frame = CGRect(x: 0, y: supportView.bounds.midY - 15.0, width: UIDevice.isIpad ? supportView.bounds.width - splitViewController!.primaryColumnWidth : supportView.bounds.width, height: 30.0)
        supportView.addSubview(supportLbl)
        self.view.addSubview(supportView)
    }
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = UIColor.bgMainColor
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
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func showScanner() {
        let qrReader = QRReaderVC()
        qrReader.delegate = self
        self.present(qrReader, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let searchText = searchBar.text else {
            return
        }
        DispatchQueue.main.async {
            if self.needAddTokenAnimation {
                self.needAddTokenAnimation = false
                self.supportLbl.text = NSLocalizedString("TokenAdded", comment: "")
                UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseInOut, animations: {
                    self.supportView.frame.origin.y = self.view.bounds.height - 58.0
                }, completion: { _ in
                    UIView.animate(withDuration: 0.7, delay: 0.5, options: .curveEaseInOut
                        , animations: {
                            self.supportView.frame.origin.y = self.view.bounds.height
                    })
                })
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
        self.title = NSLocalizedString("Add new token", comment: "")
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.title = NSLocalizedString("Wallet", comment: "")
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
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showScanner()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    self.showScanner()
                }
            }
        case .denied:
            self.present(UIAlertController.accessCameraAlert(), animated: true, completion: nil)
        case .restricted:
            break
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TokenTableViewCell.identifier, for: indexPath) as? TokenTableViewCell
        cell?.isSearchable = true
        let num = floor(Double(indexPath.row/2))
        let token = tokensList![Int(num)]
        cell?.token = token
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let num = floor(Double(indexPath.row/2))
        let tokenToAdd = self.tokensList![Int(num)]
        if tokenToAdd.isAdded {
            supportLbl.text = NSLocalizedString("tokenIsAdded", comment: "")
            if !isAnimating {
                isAnimating = true
                UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
                    self.supportView.frame.origin.y = self.view.bounds.height - 58.0
                }) { _ in
                    UIView.animate(withDuration: 0.6, delay: 0.5, options: .curveEaseInOut, animations: {
                        self.supportView.frame.origin.y = self.view.bounds.height
                    }) { _ in
                        self.isAnimating = false
                    }
                }
            }
            return
        }
        chosenToken = tokenToAdd
        performSegue(withIdentifier: "addChosenToken", sender: self)
    }
}

extension CreateTokenController:TokenInfoControllerDelegate {
    func didAddToken() {
        //
    }
}



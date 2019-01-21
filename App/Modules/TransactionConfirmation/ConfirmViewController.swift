//
//  ConfirmViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 24.06.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift
import BigInt
import Amplitude_iOS

class ConfirmViewController: UITableViewController {
    
    //IBOutlets
    
    @IBOutlet weak var fromLabel:UILabel!
    @IBOutlet weak var toLabel:UILabel!
    @IBOutlet weak var amountLabel:UILabel!
    @IBOutlet weak var feeLabel:UILabel!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var totalLabel:UILabel!
    
    var fromAddr:String {
        let addr = keyService.selectedAddress() ?? ""
        return addr
    }
    override var navigationBarAppearance: NavigationBarAppearance? {
        get {
            let barTintColor: UIColor = UIDevice.isIpad ? .white : .mainColor
            let tintColor: UIColor = UIDevice.isIpad ? .black : .white
            let statusBarStyle: UIStatusBarStyle = UIDevice.isIpad ? .default : .lightContent
            return super.navigationBarAppearance ?? NavigationBarAppearance(barTintColor: barTintColor, tintColor: tintColor, titleTextAttributes: nil, statusBarStyle: statusBarStyle, shadowImage: UIImage())
        }
        set {
            super.navigationBarAppearance = newValue
        }
    }
    var gasPrice:String!
    var gasLimit:String!
    var transaction:TransactionIntermediate!
    lazy var fee: String? = self.formattedFee()
    var amount:String!
    var name: String!
    var isAuth:Bool = true
    var isPinAccepted = false
    let tokenService = CustomERC20TokensServiceImplementation()
    let keyService = SingleKeyServiceImplementation()
    var selectedToken:ERC20TokenModel {
        return tokenService.selectedERC20Token()
    }
    var isEthToken:Bool {
        return selectedToken.address.isEmpty
    }
    
    @IBAction func unwindBackToConfirm(segue:UIStoryboardSegue) { }

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavBar()
        configureTableView()
    }

    func prepareNavBar() {
        navigationItem.titleView = UIDevice.isIpad ? UIView.titleLabel(.black) : UIView.titleLabel()
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1))
        tableView.backgroundColor = UIColor(hex:"F9F9F9")
        tableView.estimatedRowHeight = 360
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func configure(_ dict:[String:Any]) {
        gasLimit = dict["gasLimit"] as? String
        gasPrice = dict["gasPrice"] as? String
        transaction = dict["transaction"] as? TransactionIntermediate
        amount = dict["amount"] as? String
        name = dict["name"] as? String
    }
    
    func updateUI() {
        let symbol = selectedToken.symbol.uppercased()
        toLabel.text = transaction.transaction.to.address.formattedAddrToken(number:5)
        amountLabel.text = "\(amount!) \(symbol)"
        fromLabel.text = fromAddr.formattedAddrToken(number:5)
        feeLabel.text = "\(fee!) \(symbol)"
        walletNameLabel.text = name
        isAuth = UserDefaults.standard.value(forKey:Keys.sendSwitch.rawValue) as? Bool ?? true
        guard let feeString = fee, let feeNumber = Float(feeString),let amountString = amount, let amountNumber = Float(amountString) else { return }
        let total = feeNumber + amountNumber
        totalLabel.text = "\(total) \(symbol)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isPinAccepted { self.sendFunds() }
        updateUI()
    }
    
    //Helper
    
    func formattedFee() -> String? {
        guard let gasNumber = Double(self.gasPrice) else { return nil }
        let gasPrice = BigUInt(gasNumber * pow(10, 9))
        guard let gasLimit = BigUInt(self.gasLimit) else { return "" }
        return Web3.Utils.formatToEthereumUnits((gasPrice * gasLimit), toUnits: .eth, decimals: 7)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let successVC = segue.destination as? SendingSuccessViewController, let sentTrans = sender as? TransactionSendingResult {
            
            successVC.transactionAmount = Web3.Utils.formatToEthereumUnits(sentTrans.transaction.value, toUnits: .eth)
            successVC.addressToSend = sentTrans.transaction.to.address
        } else if let errorVC = segue.destination as? SendingErrorViewController {
            guard let error = sender as? String else { return }
            errorVC.error = error
        }
    }
    
    func sendFunds() {
        let sendEthService: SendEthService = isEthToken ? SendEthServiceImplementation() : ERC20TokenContractMethodsServiceImplementation()
        let token  = self.tokenService.selectedERC20Token()
        let model = ETHTransactionModel(hash: nil, from: self.fromAddr, to: self.toLabel.text ?? "", amount: self.amount, date: Date(), token: token, key:self.keyService.selectedKey()!, isPending: true)
        self.performSegue(withIdentifier: "waitSegue", sender: nil)
        var options = Web3Options.defaultOptions()
        options.gasLimit = BigUInt(self.gasLimit)
        let gp = BigUInt(Double(self.gasPrice)! * pow(10, 9))
        options.gasPrice = gp
        options.from = self.transaction.options?.from
        options.to = self.transaction.options?.to
        options.value = self.transaction.options?.value
        sendEthService.send(transactionModel: model, transaction: self.transaction, options: options) { (result) in
            switch result {
            case .Success(let res):
                Amplitude.instance().logEvent("Transaction Sent")
                self.performSegue(withIdentifier: "successSegue", sender: res)
            case .Error(let error):
                var valueToSend = ""
                if let error = error as? Web3Error {
                    switch error {
                    case .nodeError(let text):
                        valueToSend = text
                    default:
                        break
                    }
                }
                self.performSegue(withIdentifier: "showError", sender: valueToSend)
            }
        }
    }
    
    //TODO: - show PIN here
    @IBAction func sendTapped() {
        if isAuth {
            if isPinAccepted {
                self.sendFunds()
            } else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.showPasscode(context: .sendScreen(self))
            }
        } else {
            self.sendFunds()
        }
    }
}


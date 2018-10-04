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
    
    //Properties
    
    
    var fromAddr:String {
        guard let addr = getFromAddress() else { return " " }
        return addr
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
    var selectedToken:ERC20TokenModel?
    var isEthToken:Bool {
        guard let token = selectedToken else { return false }
        return token.address.isEmpty
    }
    
    @IBAction func unwindBackToConfirm(segue:UIStoryboardSegue) { }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let label = UILabel()
        label.text = "Send"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        navigationItem.titleView = label
        configureTableView()
    }
    
    
    // MARK: - Table view data source
    
    func configureTableView() {
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1))
        tableView.backgroundColor = UIColor(hex:"F9F9F9")
    }
    
    func configure(_ dict:[String:Any]) {
        gasLimit = dict["gasLimit"] as? String
        gasPrice = dict["gasPrice"] as? String
        transaction = dict["transaction"] as? TransactionIntermediate
        amount = dict["amount"] as? String
        name = dict["name"] as? String
    }
    
    func updateUI() {
        let symbol = isEthToken ? "ETH" : selectedToken!.symbol.uppercased()
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
        navigationController?.navigationBar.barTintColor = WalletColors.mainColor
        navigationController?.navigationBar.tintColor = .white
        UIApplication.shared.statusBarView?.backgroundColor = WalletColors.mainColor
        UIApplication.shared.statusBarStyle = .lightContent
        if isPinAccepted { self.sendFunds() }
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = WalletColors.mainColor
        UIApplication.shared.statusBarView?.backgroundColor = .white
        UIApplication.shared.statusBarStyle = .default
    }
    
    
    
    //Helper
    
    func getFromAddress() -> String? {
        let service = SingleKeyServiceImplementation()
        let addr = service.selectedWallet()?.address
        return addr
    }
    
    func formattedFee() -> String? {
        let gasPrice = BigUInt(Double(self.gasPrice)! * pow(10, 9))
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
        } else if let vc = segue.destination as? PasscodeEnterController {
            vc.instanciatedFromSend = true
        }
    }
    
    func sendFunds() {
        let sendEthService: SendEthService = self.tokenService.selectedERC20Token().address.isEmpty ? SendEthServiceImplementation() : ERC20TokenContractMethodsServiceImplementation()
        let token  = self.tokenService.selectedERC20Token()
        let model = ETHTransactionModel(from: self.fromAddr, to: self.toLabel.text ?? "", amount: self.amount, date: Date(), token: token, key:self.keyService.selectedKey()!, isPending: true)
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
                self.performSegue(withIdentifier: "showPIN", sender: nil)
            }
//            TouchManager.authenticateBioMetrics(reason: "", success: {
//                self.sendFunds()
//            }) { (error) in
//                print(error.getErrorMessage())
//            }
        } else {
            self.sendFunds()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return UIScreen.main.bounds.height - (233 + 186)
        }else if indexPath.row == 0 {
            return 233
        }else {
            return 62
        }
    }
    
    
    
    
}


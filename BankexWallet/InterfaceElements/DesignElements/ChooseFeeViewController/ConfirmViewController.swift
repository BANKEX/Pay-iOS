//
//  ConfirmViewController.swift
//  BankexWallet
//
//  Created by Vladislav on 24.06.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class ConfirmViewController: UITableViewController {
    
    //IBOutlets
    
    @IBOutlet weak var fromLabel:UILabel!
    @IBOutlet weak var toLabel:UILabel!
    @IBOutlet weak var gasPriceLabel:UILabel!
    @IBOutlet weak var amountLabel:UILabel!
    @IBOutlet weak var feeLabel:UILabel!
    @IBOutlet weak var gasLimitLabel:UILabel!
    @IBOutlet weak var totalLabel:UILabel!
    
    
    //Properties

    
    var fromAddr:String {
        guard let addr = getFromAddress() else { return " " }
        return addr
    }
    var gasPrice:String!
    var gasLimit:String!
    var transaction:TransactionIntermediate!
    var fee:String!
    var amount:String!
    var totalFee:String {
        return String(formattedTotalFee())
    }
    
    let tokenService = CustomERC20TokensServiceImplementation()
    let keyService = SingleKeyServiceImplementation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func configureTableView() {
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1))
        tableView.separatorInset.right = 15.0
    }
    
    func configure(_ dict:[String:Any]) {
        gasLimit = dict["gasLimit"] as? String
        gasPrice = dict["gasPrice"] as? String
        transaction = dict["transaction"] as? TransactionIntermediate
        amount = dict["amount"] as? String
    }
    
    func updateUI() {
        gasLimitLabel.text = gasLimit
        gasPriceLabel.text = gasPrice
        toLabel.text = transaction.transaction.to.address
        amountLabel.text = amount
        fromLabel.text = fromAddr
        totalLabel.text = totalFee
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    //Helper
    
    func getFromAddress() -> String? {
        let service = SingleKeyServiceImplementation()
        let addr = service.selectedWallet()?.address
        return addr
    }
    
    func formattedTotalFee() -> Int {
        guard let gasPrice = Int(self.gasPrice) else { return 0 }
        guard let gasLimit = Int(self.gasLimit) else { return 0 }
        return gasPrice * gasLimit
    }
    //Just try to send the transaction. (Just a test)
    @IBAction func sendTapped() {
        self.performSegue(withIdentifier: "waitSegue", sender: nil)
        var sendEthService = SendEthServiceImplementation()
        let model = ETHTransactionModel(from: fromAddr, to: toLabel.text!, amount: amount, date: Date(), token: tokenService.selectedERC20Token(), key: keyService.selectedKey()!)
        sendEthService.send(transactionModel: model, transaction: transaction) { (result) in
            switch result {
            case .Success(let result):
                self.performSegue(withIdentifier: "successSegue", sender: nil)
            case .Error(let error):
                self.performSegue(withIdentifier: "showError1", sender: nil)
            }
        }
    }

}

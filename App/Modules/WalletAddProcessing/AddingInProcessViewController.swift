//
//  AddingInProcessViewController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/8/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class AddingInProcessViewController: BaseViewController {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var processTitleLabel: UILabel?
    @IBOutlet weak var activityView:UIActivityIndicatorView!

    
    var amountToSend: String?
    var destinationAddressToSend: String?
    var transactionToSend: TransactionIntermediate?
    var inputtedPassword: String?
    
    var textToShow: String?
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SendingSuccessViewController {
            controller.transactionAmount = transactionAmount
            controller.addressToSend = recipientAddress
        }
        guard segue.identifier == "showConfirmation",
            let confirmation = segue.destination as? SendingConfirmationController else {
                return
        }
        confirmation.amount = amountToSend
        confirmation.destinationAddress = destinationAddressToSend
        confirmation.transaction = transactionToSend
        confirmation.inputtedPassword = inputtedPassword
        amountToSend = nil
        destinationAddressToSend = nil
        transactionToSend = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        splitViewController?.hide()
        UIApplication.shared.statusBarStyle = .default
        activityView.startAnimating()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        titleLabel?.text = textToShow == nil ? NSLocalizedString("Sending funds", comment: "") : textToShow!
        processTitleLabel?.text = NSLocalizedString("Retrieving data", comment: "")
        processTitleLabel?.textColor = UIColor.sendColor
        titleLabel?.textColor = UIColor(red: 0, green: 117, blue: 254)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        splitViewController?.show()
        activityView.stopAnimating()
        textToShow = nil
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DefaultTokensServiceImplementation().downloadAllAvailableTokensIfNeeded {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if UIDevice.isIpad {
                appDelegate.showSplitVC()
            }else {
                appDelegate.showTabBar()
            }
        }
    }
    
    
    var transactionAmount: String?
    var recipientAddress: String?
    
}

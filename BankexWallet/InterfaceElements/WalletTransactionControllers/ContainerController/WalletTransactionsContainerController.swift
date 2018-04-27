//
//  WalletTransactionsContainerController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/4/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class WalletTransactionsContainerController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControlValueChanged(self)
    }

    @IBOutlet weak var historyContainerView: UIView!
    @IBOutlet weak var tokensListContainerView: UIView!
    
    @IBAction func unwind(segue:UIStoryboardSegue) { }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 0 {
            historyContainerView.isHidden = false
            tokensListContainerView.isHidden = true
        } else {
            historyContainerView.isHidden = true
            tokensListContainerView.isHidden = false
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "transactionsHistory" {
            let historyController = segue.destination as! TransactionsHistoryController
            // TODO:  think about move this to builder
            let presenter = TransactionsHistoryPresenter()
//            presenter.view = historyController
            historyController.presenter = presenter
        }
    }
 

}

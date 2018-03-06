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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwind(segue:UIStoryboardSegue) { }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "transactionsHistory" {
            let historyController = segue.destination as! TransactionsHistoryController
            // TODO:  think about move this to builder
            let presenter = TransactionsHistoryPresenter()
            presenter.view = historyController
            historyController.presenter = presenter
        }
    }
 

}

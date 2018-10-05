//
//  TodayViewController.swift
//  Wallet Widget
//
//  Created by Vladislav on 04/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import NotificationCenter


class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var balanceLabel:UILabel!
    @IBOutlet weak var nameWallet:UILabel!
    
    enum Keys {
        case balance
        case nameWallet
        
        func key() -> String {
            switch self {
            case .balance: return "Balance"
            case .nameWallet: return "Name"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        balanceLabel.text = "..."
        nameWallet.text = "..."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
   
    
    func updateUI(completion:((Bool) -> ())? = nil) {
        let userDefault = UserDefaults(suiteName: "group.PayWidget")
        guard let balance = userDefault?.string(forKey: Keys.balance.key()),let name = userDefault?.string(forKey: Keys.nameWallet.key()) else {
            completion?(false)
            return
        }
        balanceLabel.text = balance
        nameWallet.text = name
        completion?(true)
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        updateUI { isSuccess in
            if !isSuccess {
                completionHandler(NCUpdateResult.noData)
                return
            }
            completionHandler(NCUpdateResult.newData)
        }
    }
    
}

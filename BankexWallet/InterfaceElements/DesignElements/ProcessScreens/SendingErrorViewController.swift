//
//  SendingErrorViewController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/8/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

protocol Retriable {
    func retryExisitngTransaction()
}

class SendingErrorViewController: BaseViewController {
    
    var error: String?
    
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackButton()
        layoutTitle()
    }
    
    func layoutTitle() {
        let lbl = UILabel()
        lbl.text = "Send"
        lbl.font = UIFont.systemFont(ofSize: 17.0, weight:.semibold)
        lbl.textColor = .white
        navigationItem.titleView = lbl
    }
    
    @IBAction func retryTransaction(_ sender: Any) {
        self.performSegue(withIdentifier:"unwindToSend", sender: error)
//        let count = navigationController?.viewControllers.count ?? 3
//
//        if  count >= 3, let previousController = navigationController?.viewControllers[count - 3] as? SendTokenViewController
//        {
//            //previousController.retryExisitngTransaction()
//            navigationController?.popToViewController(previousController as UIViewController, animated: false)
//
//        } else {
//            navigationController?.popToRootViewController(animated: false)
//        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SendTokenViewController {
            if error == nil {
                vc.retryExisitngTransaction()
            }
            vc.errorMessage = error
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.barTintColor = WalletColors.mainColor
        UIApplication.shared.statusBarView?.backgroundColor = WalletColors.mainColor
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.barTintColor = .white
        UIApplication.shared.statusBarView?.backgroundColor = .white
        navigationController?.navigationBar.tintColor = WalletColors.mainColor
    }
    
    func addBackButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "BackArrow"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        button.setTitle(" \(NSLocalizedString("Wallet", comment: ""))", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(done(_:)), for: .touchUpInside)
    }
    
    @IBAction func done(_ sender: Any) {
        navigationController?.popToRootViewController(animated: false)
    }
}

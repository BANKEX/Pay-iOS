//
//  SendingSuccessViewController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/8/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class SendingSuccessViewController: UIViewController {

    // MARK: All the data we need
    var transactionAmount: String?
    var addressToSend: String?
    let favoritesService: RecipientsAddressesService = RecipientsAddressesServiceImplementation()
    let tokenService: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    
    // MARK:  Outlets
    @IBOutlet weak var transactionSucceedLabel: UILabel!
    @IBOutlet weak var addToFavoritesView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackButton()
    }
    
    // MARK:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if favoritesService.contains(address: addressToSend ?? "") {
            addToFavoritesView.isHidden = true
        }
        if let amount = transactionAmount {
            transactionSucceedLabel.text = "Your \(amount) \(tokenService.selectedERC20Token().symbol) has been sent successfully"
        }
    }
    
    func addBackButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "BackArrow"), for: .normal)
        button.setTitle("  Home", for: .normal)
        button.setTitleColor(WalletColors.blueText.color(), for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(done(_:)), for: .touchUpInside)
    }
    
    // MARK: Actions

    @IBAction func done(_ sender: Any) {
        navigationController?.popToRootViewController(animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? CreateNewContact {
            controller.addContact(with: addressToSend ?? "")
        }
    }
}

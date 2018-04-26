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
    
    // MARK: Actions

    @IBAction func done(_ sender: Any) {
        navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func addToFavorites(_ sender: Any) {
        // TODO: Open save contact screen
        // TODO: Start to show button again! 
    }
}

//
//  CreateTokenController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 3/15/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class CreateTokenController: UIViewController {

    @IBOutlet weak var tokenDecimalsLabel: UILabel!
    @IBOutlet weak var tokenSymbolLabel: UILabel!
    @IBOutlet weak var tokenNameLabel: UILabel!
    
    @IBOutlet weak var findContractButton: UIButton!
    @IBOutlet weak var contractAddressTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contractAddressTextfield.becomeFirstResponder()
    }

    var hasFoundToken = false
    let tokensService: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    var foundModel: ERC20TokenModel?
    
    @IBAction func findContract(_ sender: Any) {
        guard let tokenAddress = contractAddressTextfield.text, !tokenAddress.isEmpty else {
            return
        }
        if hasFoundToken {
            // TODO: Add Token
            guard let foundModel = foundModel else {
                return
            }
            tokensService.addNewCustomToken(with: foundModel.address,
                                            name: foundModel.name,
                                            decimals: foundModel.decimals,
                                            symbol: foundModel.symbol)
            
        } else {
            // TODO: Search For token
            tokensService.searchForCustomToken(with: tokenAddress, completion: { (result) in
                
                switch result {
                case .Success(let model):
                    self.tokenNameLabel.text = model.name
                    self.tokenDecimalsLabel.text = model.decimals
                    self.tokenSymbolLabel.text = model.symbol
                    self.hasFoundToken = true
                    self.findContractButton.setTitle("Add Contract", for: .normal)
                    self.foundModel = model
                case .Error(let error):
                    print("\(error)")
                }
            })
        }
        
    }
    
}

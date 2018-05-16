//
//  CreateTokenController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 3/15/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit

class CreateTokenController: UIViewController,
UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var foundTokenView: UIView!
    @IBOutlet weak var tokenDecimalsLabel: UILabel!
    @IBOutlet weak var tokenSymbolLabel: UILabel!
    @IBOutlet weak var tokenNameLabel: UILabel!
    
    @IBOutlet weak var findContractButton: UIButton!
    @IBOutlet weak var contractAddressTextfield: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var tokenSymbolImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contractAddressTextfield.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.stopAnimating()
        emptyView.isHidden = false
        foundTokenView.isHidden = true
        findContractButton.backgroundColor = WalletColors.disableButtonBackground.color()
    }
    
    var hasFoundToken = false
    let tokensService: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    var foundModel: ERC20TokenModel?
    
    @IBAction func findContract(_ sender: Any) {
            // TODO: Add Token
            guard let foundModel = foundModel else {
                return
            }
            tokensService.addNewCustomToken(with: foundModel.address,
                                            name: foundModel.name,
                                            decimals: foundModel.decimals,
                                            symbol: foundModel.symbol)
        navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: UITextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let tokenAddress = contractAddressTextfield.text, !tokenAddress.isEmpty else {
            return true
        }
        textField.resignFirstResponder()
        self.errorLabel.isHidden = true
        self.emptyView.isHidden = false
        self.foundTokenView.isHidden = true

        activityIndicator.startAnimating()
        tokensService.searchForCustomToken(with: tokenAddress, completion: { (result) in
            self.activityIndicator.stopAnimating()
            switch result {
            case .Success(let model):
                self.tokenNameLabel.text = model.name
                self.tokenDecimalsLabel.text = model.decimals
                self.tokenSymbolLabel.text = model.symbol
                self.hasFoundToken = true
                self.findContractButton.setTitle("Add Contract", for: .normal)
                self.foundModel = model
                self.findContractButton.backgroundColor = WalletColors.defaultDarkBlueButton.color()
                self.tokenSymbolImageView.image = PredefinedTokens(with: model.name).image()
                self.emptyView.isHidden = true
                self.foundTokenView.isHidden = false
            case .Error(_):
                self.errorLabel.isHidden = false
            }
        })
        return true
    }
    
}

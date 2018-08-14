//
//  SendingConfirmationController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/8/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class SendingConfirmationController: UIViewController, Retriable {

    // MARK: Outlets
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var feeLabel: UILabel!
    
    @IBOutlet weak var stackView: UIView!
    @IBOutlet weak var nextButtonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomSpaceNextButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var internalViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    
    // MARK:
    var transaction: TransactionIntermediate?
    var amount: String?
    var destinationAddress:String?
    var inputtedPassword: String?
    
    weak var transactionCompletionDelegate: SendingResultInformation?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showSending",
            let destination = segue.destination as? SendingInProcessViewController else {
                return
        }
        transactionCompletionDelegate = destination
    }
    
    let tokensService = CustomERC20TokensServiceImplementation()
    let keysService: SingleKeyService = SingleKeyServiceImplementation()

    @IBAction func nextButtonTapped(_ sender: Any) {
        let sendEthService: SendEthService = tokensService.selectedERC20Token().address.isEmpty ?
            SendEthServiceImplementation() :
            ERC20TokenContractMethodsServiceImplementation()
        
        let token = tokensService.selectedERC20Token()
        let transactionModel = ETHTransactionModel(from: keysService.selectedAddress() ?? "",
                                                   to: destinationAddress ?? "",
                                                   amount: (amount ?? "") + " " + token.symbol,
                                                   date: Date(),
                                                   token: token,
                                                   key: keysService.selectedKey()!, isPending: true)

        
        performSegue(withIdentifier: "showSending", sender: self)
        sendEthService.send(transactionModel: transactionModel,
                            transaction: transaction!,
                            with: inputtedPassword ?? "", options: nil) { (result) in
                                switch result {
                                case .Success(_):
                                    self.transactionCompletionDelegate?.transactionDidSucceed(withAmount: self.amount ?? "", address: self.destinationAddress ?? "")
                                case .Error(_):
                                    //TODO:
                                    self.transactionCompletionDelegate?.transactionDidFail()

                                }
//                                }
        }//transaction?.send(password: inputtedPassword ?? "", options: nil)
    }
    
    @IBOutlet weak var feeFullView: UIView!
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let fixedFrame = view.convert(stackView.frame, from: stackView.superview)
        var viewHeight: CGFloat =  -fixedFrame.minY
        if #available(iOS 11.0, *) {
            viewHeight -= view.safeAreaInsets.bottom
            viewHeight -= view.safeAreaInsets.top

            bottomSpaceNextButtonConstraint.constant = 0
        }
        internalViewHeightConstraint.constant = viewHeight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toAddressLabel.text = destinationAddress
        fromAddressLabel.text = SingleKeyServiceImplementation().selectedAddress()
        amountLabel.text = (amount ?? "") + " " + tokensService.selectedERC20Token().symbol
        guard let estimatedGas = transaction?.estimateGas(options: nil).value else {
            feeLabel.text = "Not defined"
            return
        }
        let formattedAmount = Web3.Utils.formatToEthereumUnits(estimatedGas, toUnits: .wei, decimals: 1)

        feeLabel.text = (formattedAmount ?? "") + " Wei."
        nextButton.setTitle("Send " + (amountLabel.text ?? ""), for: .normal)
    }
    
    // MARK: Retriable
    func retryExisitngTransaction() {
        nextButtonTapped(self)
    }

}

//
//  ChooseFeeViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 25/07/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class ChooseFeeViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var currencySymbolLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasPriceSlider: UISlider!
    @IBOutlet weak var gasLimitTextField: UITextField!
    @IBOutlet weak var gasLimitSlider: UISlider!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var interDataAndButtonConstraint: NSLayoutConstraint!
    //MARK: - Variables
    var amount: String!
    var destinationAddress: String!
    var transaction: TransactionIntermediate!
    
    @IBOutlet weak var tokenImageView: UIImageView!
    //MARK: - Services
    var sendEthService: SendEthService!
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    let tokensService = CustomERC20TokensServiceImplementation()
    lazy var utilsService: UtilTransactionsService = tokensService.selectedERC20Token().address.isEmpty ? UtilTransactionsServiceImplementation() :
    CustomTokenUtilsServiceImplementation()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Send"
        addObservers()
        configureFee()
        addBackButton()
        updateBalance()
        
        _ = textFields.map { $0.delegate = self }
    }
    
    var sendingProcess: SendingResultInformation?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ConfirmSegue" else { return }
        guard let confirmVC = segue.destination as? ConfirmViewController else { return }
        guard let gasPrice = gasPriceTextField.text else { return }
        guard let gasLimit = gasLimitTextField.text else { return }
        guard let name = walletNameLabel.text else { return }
        transaction.options?.gasLimit = BigUInt(gasLimit)
        transaction.options?.gasPrice = BigUInt(gasPrice)
        let dict:[String:Any] = ["gasPrice":gasPrice,"gasLimit":gasLimit,"transaction":transaction,"amount":amount, "name": name]
        confirmVC.configure(dict)
        guard segue.identifier == "showSending",
            let confirmation = segue.destination as? SendingResultInformation else {
                return
        }
        sendingProcess =  confirmation
        
    }
    
    
    //MARK: - Actions
    @IBAction func gasPriceSliderValueChanged(_ sender: UISlider) {
        let y = yFunc(x: sender.value)
        gasPriceTextField.text = String(describing: y.roundToDecimals())
    }
    
    func yFunc(x: Float) -> Float {
        return x * x
    }
    
    
    @IBAction func gasLimitSliderValueChanged(_ sender: UISlider) {
        let y = yFunc(x: sender.value)
        gasLimitTextField.text = String(describing: Int(y))
    }
    
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "ConfirmSegue", sender: nil)
    }
    
    @IBAction func emptySpaceTapped(_ sender: Any) {
        view.endEditing(true)
    }
    //MARK: - Helpers
    func configure(_ sender: [String: Any]) {
        amount = sender["amount"] as? String
        destinationAddress = sender["destinationAddress"] as? String
        transaction = sender["transaction"] as? TransactionIntermediate
    }
    
    func updateBalance() {
        currencySymbolLabel.text = tokensService.selectedERC20Token().symbol.uppercased()
        
        guard let selectedAddress = keysService.selectedAddress() else {
            return
        }
        walletNameLabel.text = keysService.selectedWallet()?.name
        walletAddressLabel.text = selectedAddress
        tokenImageView.image = PredefinedTokens(with: tokensService.selectedERC20Token().symbol).image()
        utilsService.getBalance(for: tokensService.selectedERC20Token().address, address: selectedAddress) { (result) in
            switch result {
            case .Success(let response):
                print("\(response)")
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                let formattedAmount = Web3.Utils.formatToEthereumUnits(response, toUnits: .eth, decimals: 4)
                self.amountLabel.text = formattedAmount
            case .Error(let error):
                print("\(error)")
            }
        }
    }
    
    
    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    func configureFee() {
        
        guard let gasLimitInt = transaction.options?.gasLimit else { return }
        guard let gasPriceInt = transaction.options?.gasPrice else { return }
        
        let initialGasPrice: Float = Float(gasPriceInt / BigUInt(pow(10.0, 9.0)))
        let initialGasLimit: Float = Float(gasLimitInt)
        
        gasPriceSlider.minimumValue = sqrt(0.5)
        gasPriceSlider.maximumValue = sqrt(200)
        gasPriceSlider.value = sqrt(initialGasPrice)
        gasPriceTextField.text = String(describing: initialGasPrice)
        
        
        gasLimitSlider.minimumValue = 0
        gasLimitSlider.maximumValue = sqrt(10000000)
        gasLimitSlider.value = sqrt(initialGasLimit)
        gasLimitTextField.text = String(describing: Int(initialGasLimit))
        gasPriceTextField.placeholder = String(describing: gasPriceSlider.minimumValue) + "-" + String(describing: gasPriceSlider.maximumValue)
        gasLimitTextField.placeholder = String(describing: gasLimitSlider.minimumValue) + "-" + String(describing: gasLimitSlider.maximumValue)
    }
    
    func addBackButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "BackArrow"), for: .normal)
        button.setTitle("  Home", for: .normal)
        button.setTitleColor(WalletColors.blueText.color(), for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: Keyboard
    @objc func keyboardDidHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
        
        UIView.animate(withDuration: duration,
                       delay: TimeInterval(0),
                       options: animationCurve,
                       animations: {
                        self.scrollView.contentInset = UIEdgeInsets.zero
                        self.scrollView.contentOffset = CGPoint.zero
                        
        },
                       completion: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let endFrameHeight = endFrame?.size.height ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            let textField = textFields.first {$0.isFirstResponder}
            let textFieldFrameY = (textField?.frame.maxY ?? 0) + 50
            var  newOffset: CGFloat = 0
            if textFieldFrameY > view.frame.maxY - endFrameHeight && textField != nil {
                newOffset = textFieldFrameY - (view.frame.maxY - endFrameHeight)
            }
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            if endFrameY >= UIScreen.main.bounds.size.height {
                                self.scrollView.contentInset = UIEdgeInsets.zero
                            } else {
                                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, endFrame?.size.height ?? 0.0, 0)
                            }
                            self.scrollView.contentOffset = CGPoint(x: 0, y: newOffset)
                            
            },
                           completion: nil)
        }
    }
    
    
    
    
}

extension ChooseFeeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done && sendButton.isEnabled {
            sendButtonTapped(self)
        } else if textField.returnKeyType == .next {
            let index = textFields.index(of: textField) ?? 0
            let nextIndex = (index == textFields.count - 1) ? 0 : index + 1
            textFields[nextIndex].becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "")  as NSString
        let futureString = currentText.replacingCharacters(in: range, with: string) as String
        sendButton.isEnabled = false
        
        switch textField {
        case gasPriceTextField:
            if !futureString.isEmpty && !(gasLimitTextField.text?.isEmpty ?? true) {
                sendButton.isEnabled = true
            }
            
            if let floatRepresentation = Float(futureString) {
                gasPriceSlider.value = floatRepresentation
            }
        case gasLimitTextField:
            if !futureString.isEmpty && !(gasPriceTextField.text?.isEmpty ?? true) {
                sendButton.isEnabled = true
            }
            
            if let floatRepresentation = Float(futureString) {
                gasLimitSlider.value = floatRepresentation
            }
            
        default:
            sendButton.isEnabled = false
        }
        
        sendButton.backgroundColor = sendButton.isEnabled ? WalletColors.defaultDarkBlueButton.color() : WalletColors.disableButtonBackground.color()
        textField.returnKeyType = sendButton.isEnabled ? UIReturnKeyType.done : .next
        
        return true
    }
}

public extension Float {
    func roundToDecimals(decimals: Int = 2) -> Float {
        let multiplier = Float(10^decimals)
        return (multiplier * self).rounded() / multiplier
    }
}




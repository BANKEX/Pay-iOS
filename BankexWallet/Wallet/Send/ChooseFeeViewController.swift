//
//  ChooseFeeViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 25/07/2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class ChooseFeeViewController: BaseViewController {
    
    enum StateButtons {
        case enable,disable
    }
    
    
    //MARK: - Outlets
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasLimitTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var infoView:InfoView!
    @IBOutlet weak var heightConstraint:NSLayoutConstraint!
    
    
    
    //MARK: - Variables
    var state:StateButtons! {
        didSet {
            if state == .enable {
                sendButton.isEnabled = true
                sendButton.backgroundColor = UIColor.mainColor
            }else {
                sendButton.isEnabled = false
                sendButton.backgroundColor = UIColor.disableColor
            }
        }
    }
    lazy var unitLabel:UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.text = "Gwei"
        label.textColor = UIColor.blackColor
        return label
    }()
    var amount: String!
    var destinationAddress: String?
    var transaction: TransactionIntermediate?
    //MARK: - Services
    var sendEthService: SendEthService!
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    let tokensService = CustomERC20TokensServiceImplementation()
    var currentBalance:String?
    var selectedToken:ERC20TokenModel?
    var isEthToken:Bool {
        guard let token = selectedToken else { return false }
        return token.address.isEmpty
    }
    var isCorrectValuePrice:Bool {
        guard let str = gasPriceTextField.text else { return false }
        guard let value = Float(str) else { return false }
        return value >= 1.0 && value <= 99.0
    }
    var isCorrectValueLimit:Bool {
        guard let _ = gasLimitTextField.text else { return false }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Wallet", comment: "")
        heightConstraint.setMultiplier(multiplier: UIDevice.isIpad ? 1/4.76 : 1/3.3)
        addObservers()
        setupTextFields()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        UIApplication.shared.statusBarStyle = UIDevice.isIpad ? .default : .lightContent
        UIApplication.shared.statusBarView?.backgroundColor = UIDevice.isIpad ? .white : UIColor.mainColor
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        UIApplication.shared.statusBarStyle = .default
    }
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var sendingProcess: SendingResultInformation?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ConfirmSegue" else { return }
        guard let confirmVC = segue.destination as? ConfirmViewController else { return }
        guard let gasPrice = gasPriceTextField.text else { return }
        guard let gasLimit = gasLimitTextField.text else { return }
        guard let name = infoView.nameWallet.text else { return }
        let dict:[String:Any] = ["gasPrice":gasPrice,"gasLimit":gasLimit,"transaction":transaction,"amount":amount, "name": name]
        confirmVC.configure(dict)
        guard segue.identifier == "showSending",
            let confirmation = segue.destination as? SendingResultInformation else {
                return
        }
        sendingProcess =  confirmation
    }
    
    private func setupTextFields() {
        gasPriceTextField.placeholder = "1-99"
        gasLimitTextField.placeholder = "21000-10000000"
        _ = textFields.map { $0.delegate = self }
        [gasPriceTextField,gasLimitTextField].forEach { $0?.returnKeyType = .next }
    }
    
    private func updateUI() {
        infoView.state = isEthToken ? .Eth : .Token
        guard let selectedToken = selectedToken else { return }
        infoView.balanceLabel.text = currentBalance ?? "..."
        infoView.nameTokenLabel.text = selectedToken.symbol.uppercased()
        if let selectedWallet = keysService.selectedWallet() {
            infoView.nameWallet.text = selectedWallet.name
            infoView.addrWallet.text = selectedWallet.address.formattedAddrToken(number: 10)
        }
        infoView.tokenNameLabel?.text = selectedToken.name
        configureFee()
        state = isCorrectValuePrice && isCorrectValueLimit ? .enable : .disable
        let xOffSet = gasPriceTextField.frame.origin.x + gasPriceTextField.text!.size(gasPriceTextField.font!).width
        unitLabel.frame = CGRect(x: xOffSet, y: -1, width: 65.0, height: gasPriceTextField.bounds.height)
        gasPriceTextField.addSubview(unitLabel)
    }
    
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "ConfirmSegue", sender: nil)
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
        
        guard let gasLimitInt = transaction?.options?.gasLimit else { return }
        guard let gasPriceInt = transaction?.options?.gasPrice else { return }
        
        let initialGasPrice: Float = Float(gasPriceInt / BigUInt(pow(10.0, 9.0)))
        let initialGasLimit: Float = Float(gasLimitInt)
        gasPriceTextField.text = String(describing: initialGasPrice)
        gasLimitTextField.text = String(describing: Int(initialGasLimit))
    }
    
    @IBAction func backButtonTapped() {
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
                        self.view.frame.origin.y = 0
                        
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
            if endFrameY <= gasLimitTextField.bottomY && !gasPriceTextField.isFirstResponder {
                UIView.animate(withDuration: duration,
                               delay: TimeInterval(0),
                               options: animationCurve,
                               animations: {
                                UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: {
                                    let offSet = self.gasLimitTextField.bottomY - endFrameY
                                    self.view.frame.origin.y = -(offSet + 5.0)
                                }, completion: nil)
                                
                },
                               completion: nil)
            }
            
        }
    }

    
    
    
    
}

extension ChooseFeeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .go && sendButton.isEnabled {
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
        state = .disable
        
        switch textField {
        case gasPriceTextField:
            if futureString.isEmpty {
                unitLabel.frame.origin.x = textField.frame.origin.x + textField.placeholder!.size(textField.font!).width
            }else {
                unitLabel.frame.origin.x = textField.frame.origin.x + futureString.size(textField.font!).width
            }
            if !futureString.isEmpty && isCorrectValueLimit && isCorrectValuePrice {
                state = .enable
            }
        case gasLimitTextField:
            if !futureString.isEmpty && isCorrectValuePrice && isCorrectValueLimit {
                state = .enable
            }
        default:
            state = .disable
        }
        textField.returnKeyType = state == .enable ? UIReturnKeyType.go : .next
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.textColor = UIColor.blackColor
        unitLabel.textColor = UIColor.blackColor
        textField.returnKeyType = isCorrectValuePrice && isCorrectValueLimit ? .go : .next
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if !isCorrectValuePrice {
            gasPriceTextField.textColor = UIColor.errorColor
            if gasPriceTextField.text == "" {
                unitLabel.textColor = UIColor.blackColor
            }
            unitLabel.textColor = UIColor.errorColor
            state = .disable
        }else if !isCorrectValueLimit {
            gasLimitTextField.textColor = UIColor.errorColor
            state = .disable
        }
        return true
    }
}





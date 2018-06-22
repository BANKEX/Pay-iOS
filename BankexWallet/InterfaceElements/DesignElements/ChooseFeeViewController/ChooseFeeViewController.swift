//
//  ChooseFeeViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 21/06/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class ChooseFeeViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasPriceSlider: UISlider!
    @IBOutlet weak var gasLimitTextField: UITextField!
    @IBOutlet weak var gasLimitSlider: UISlider!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet var textFields: [UITextField]!
    
    //MARK: - Variables
    var amount: String!
    var destinationAddress: String!
    var transaction: TransactionIntermediate!
    
    //MARK: - Services
    var sendEthService: SendEthService!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        configureFee()
        
        _ = textFields.map { $0.delegate = self }
    }
    
    var sendingProcess: SendingResultInformation?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showSending",
            let confirmation = segue.destination as? SendingResultInformation else {
                return
        }
        sendingProcess =  confirmation
    }
    //MARK: - Actions
    
    @IBAction func gasPriceSliderValueChanged(_ sender: UISlider) {
        gasPriceTextField.text = String(describing: Int(sender.value))
    }
    
    
    @IBAction func gasLimitSliderValueChanged(_ sender: UISlider) {
        gasLimitTextField.text = String(describing: Int(sender.value))
    }
    
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        //Here should final confirmation controller appears
        
        guard let gasPrice = gasPriceTextField.text, let gasLimitString = gasLimitTextField.text, let gasLimit = UInt(gasLimitString) else { return }
        
        
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
        
        gasPriceSlider.minimumValue = 0.5
        gasPriceSlider.maximumValue = 200
        gasPriceSlider.value = initialGasPrice
        gasPriceTextField.text = String(describing: initialGasPrice)
        
        
        gasLimitSlider.minimumValue = 0
        gasLimitSlider.maximumValue = 10000000
        gasLimitSlider.value = initialGasLimit
        gasLimitTextField.text = String(describing: initialGasLimit)
        gasPriceTextField.placeholder = String(describing: gasPriceSlider.minimumValue) + "-" + String(describing: gasPriceSlider.maximumValue)
        gasLimitTextField.placeholder = String(describing: gasLimitSlider.minimumValue) + "-" + String(describing: gasLimitSlider.maximumValue)
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



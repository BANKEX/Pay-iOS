//
//  ChooseFeeViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 21/06/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class ChooseFeeViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasPriceSlider: UISlider!
    @IBOutlet weak var gasLimitTextField: UITextField!
    @IBOutlet weak var gasLimitSlider: UISlider!
    
    @IBOutlet var textFields: [UITextField]!
    
    //MARK: - Variables
    var amount: String!
    var destinationAddress: String!
    
    //MARK: - Services
    var sendEthService: SendEthService!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        
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
    @IBAction func sendButtonTapped(_ sender: Any) {
        //Here should final confirmation controller appears
        
        guard let gasPrice = gasPriceTextField.text, let gasLimitString = gasLimitTextField.text, let gasLimit = UInt(gasLimitString) else { return }
        
        
    }
    
    //MARK: - Helpers
    func configure(_ sender: [String: String]) {
        amount = sender["amount"]
        destinationAddress = sender["destinationAddress"]
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

//
//  PasscodeEnterController.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 25.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import LocalAuthentication

class PasscodeEnterController: UIViewController {
    
    enum passcodeStatus: String {
        case enter = "Touch ID or Enter Passcode"
        case wrong = "Wrong passcode"
        case ready = "Ready"
    }
    
    @IBOutlet weak var messageLabel: UILabel!
    var passcode: String = ""
    var status: passcodeStatus = .enter
    
    @IBOutlet weak var firstNum: UIImageView!
    @IBOutlet weak var secondNum: UIImageView!
    @IBOutlet weak var thirdNum: UIImageView!
    @IBOutlet weak var fourthNum: UIImageView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var biometricsButton: UIButton!
    
    var numsIcons: [UIImageView]?
    var instanciatedFromSend = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        changePasscodeStatus(.enter)
        numsIcons = [firstNum, secondNum, thirdNum, fourthNum]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if SecurityViewController.isEnabled {
            enterWithBiometrics()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func changePasscodeStatus(_ newStatus: passcodeStatus) {
        status = newStatus
        messageLabel.text = status.rawValue
        if status == .wrong {
            passcode = ""
            changeNumsIcons(0)
        } else if status == .ready {
            enterWallet()
        }
    }
    
    private func configureBackground() {
        if instanciatedFromSend {
            backgroundImageView.image = UIImage(named: "pin-greybackground")
        }
    }
    func checkPin(_ passcode: String) -> Bool {
        do {
            let passcodeItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: "BANKEXFOUNDATION",
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPasscode = try passcodeItem.readPassword()
            return passcode == keychainPasscode
        } catch {
            fatalError("Error reading password from keychain - \(error)")
        }
    }
    
    func enterWallet() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            if let vc = currentPasscodeViewController, vc.navigationController == nil {
                vc.dismiss(animated: true, completion: nil)
                currentPasscodeViewController = nil
            } else {
                self.performSegue(withIdentifier: "showProcessFromPin", sender: self)
            }
            
        }
        
    }
    
    func changeNumsIcons(_ nums: Int) {
        switch nums {
        case 0:
            for i in 0...(numsIcons?.count)!-1 {
                self.numsIcons![i].image = UIImage(named: "white_line")
            }
        case 4:
            for i in 0...nums-1 {
                self.numsIcons![i].image = UIImage(named: "White_dot")
            }
        default:
            for i in 0...nums-1 {
                self.numsIcons![i].image = UIImage(named: "White_dot")
            }
            for i in nums...(numsIcons?.count)!-1 {
                self.numsIcons![i].image = UIImage(named: "white_line")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
        let context = LAContext()
        var error: NSError?
        if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) || !SecurityViewController.isEnabled {
            biometricsButton.alpha = 0.0
            biometricsButton.isUserInteractionEnabled = false
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func numberTouchedDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05,
                       animations: {
                        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)},
                       completion: nil)
    }
    
    
    
    @IBAction func numberPressed(_ sender: enterPinCodeNumberButton) {
        let number = sender.currentTitle!
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.05,
                           animations: {
                            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { _ in
                UIView.animate(withDuration: 0.05) {
                    sender.transform = CGAffineTransform.identity
                    
                }
            })
        }
        
        if status == .enter {
            passcode += number
            changeNumsIcons(passcode.count)
            if passcode.count == 4 {
                let newStatus: passcodeStatus = checkPin(passcode) ? .ready : .wrong
                changePasscodeStatus(newStatus)
            }
        } else if status == .wrong {
            changePasscodeStatus(.enter)
            passcode += number
            changeNumsIcons(passcode.count)
        }
        
    }
    
    
    
    @IBAction func deletePressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.05,
                           animations: {
                            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { _ in
                UIView.animate(withDuration: 0.05) {
                    sender.transform = CGAffineTransform.identity
                    
                }
            })
        }
        if passcode != "" {
            passcode.removeLast()
            changeNumsIcons(passcode.count)
        }
    }
    
    @IBAction func biometricsPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.05,
                           animations: {
                            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { _ in
                UIView.animate(withDuration: 0.05) {
                    sender.transform = CGAffineTransform.identity
                    
                }
            })
        }
        enterWithBiometrics()
    }
    
    func enterWithBiometrics() {
        let touchManager = TouchManager()  //WTF!!!
        
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            var type = "Touch ID"
            if #available(iOS 11, *) {
                switch(context.biometryType) {
                case .touchID:
                    type = "Touch ID"
                case .faceID:
                    type = "Face ID"
                case .none:
                    type = "Error"
                }
            }
            
            let reason = "Authenticate with " + type
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reason,
                                   reply:
                {(succes, error) in
                    
                    if succes {
                        self.enterWallet()
                    }
                    
            })
        }
    }
    
    func showAlertController(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SendingInProcessViewController {
            vc.fromEnterScreen = true
        } else if let vc = segue.destination as? ConfirmViewController {
            vc.isPinAccepted = true
        }
    }
    
}

class enterPinCodeNumberButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.layer.masksToBounds = false
        self.layer.cornerRadius = self.bounds.size.width/2
        //elf.clipsToBounds = true
    }
}

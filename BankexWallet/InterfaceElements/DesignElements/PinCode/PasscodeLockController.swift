//
//  PinCodeController.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 24.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class PasscodeLockController: UIViewController {
    
    enum passcodeStatus: String {
        case new = "Enter a passcode"
        case verify = "Verify your new passcode"
        case ready = "Ready"
        case wrong = "Wrong passcode"
    }
    
    @IBOutlet weak var messageLabel: UILabel!
    var passcode: String = ""
    var repeatedPasscode: String = ""
    var status: passcodeStatus = .new
    
    var passcodeItems: [KeychainPasswordItem] = []
    
    @IBOutlet weak var firstNum: UIImageView!
    @IBOutlet weak var secondNum: UIImageView!
    @IBOutlet weak var thirdNum: UIImageView!
    @IBOutlet weak var fourthNum: UIImageView!
    
    var numsIcons: [UIImageView]?
    
    let service = SingleKeyServiceImplementation()
    let router = WalletCreationTypeRouterImplementation()
    
    var address: String?
    var HDservice: HDWalletService?
    var newWallet: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changePasscodeStatus(.new)
        numsIcons = [firstNum, secondNum, thirdNum, fourthNum]
    }
    
    func changePasscodeStatus(_ newStatus: passcodeStatus) {
        status = newStatus
        messageLabel.text = status.rawValue
        if status == .wrong {
            repeatedPasscode = ""
            changeNumsIcons(0)
        } else if status == .ready {
            createWallet()
        } else if status == .verify {
            changeNumsIcons(0)
        }
    }
    
    func createWallet() {
        UserDefaults.standard.set(true, forKey: "isNotFirst")
        do {
            let passcodeItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: "BANKEXFOUNDATION",
                                                    accessGroup: KeychainConfiguration.accessGroup)
            try passcodeItem.savePassword(passcode)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
        
        UserDefaults.standard.set(true, forKey: "passcodeExists")
        UserDefaults.standard.synchronize()
        if newWallet {
            self.performSegue(withIdentifier: "fromPinToWalletCreated", sender: nil)
        } else {
            self.router.exitFromTheScreen()
        }
        
    }
    
    func changeNumsIcons(_ nums: Int) {
        switch nums {
        case 0:
            for i in 0...(numsIcons?.count)!-1 {
                self.numsIcons![i].image = UIImage(named: "empty_pin_code")
            }
        case 4:
            for i in 0...nums-1 {
                self.numsIcons![i].image = UIImage(named: "filled_pin_code")
            }
        default:
            for i in 0...nums-1 {
                self.numsIcons![i].image = UIImage(named: "filled_pin_code")
            }
            for i in nums...(numsIcons?.count)!-1 {
                self.numsIcons![i].image = UIImage(named: "empty_pin_code")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    @IBAction func numberPressed(_ sender: pinCodeNumberButton) {
        let number = sender.currentTitle!
        
        if status == .new {
            passcode += number
            changeNumsIcons(passcode.count)
            if passcode.count == 4 {
                let newStatus: passcodeStatus = .verify
                changePasscodeStatus(newStatus)
            }
        } else if status == .verify {
            repeatedPasscode += number
            changeNumsIcons(repeatedPasscode.count)
            if repeatedPasscode.count == 4 {
                let newStatus: passcodeStatus = repeatedPasscode == passcode ? .ready : .wrong
                changePasscodeStatus(newStatus)
            }
        } else if status == .wrong {
            changePasscodeStatus(.verify)
            repeatedPasscode += number
            changeNumsIcons(repeatedPasscode.count)
        }
        
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        switch status {
        case .new:
            if passcode != "" {
                passcode.removeLast()
                changeNumsIcons(passcode.count)
            }
        default:
            if repeatedPasscode != "" {
                repeatedPasscode.removeLast()
                changeNumsIcons(repeatedPasscode.count)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let address = address else { return }
        if let vc = segue.destination as? WalletCreatedViewController {
            vc.address = address
            vc.service = HDservice!
        }
    }
    
    
}

class pinCodeNumberButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
}

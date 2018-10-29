//
//  PasscodeIpadVC.swift
//  BankexWallet
//
//  Created by Vladislav on 29/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit


class PasscodeIpadVC: BaseViewController {
    
    enum passcodeStatus: String {
        case new = "Set up passcode"
        case verify = "Verify your new passcode"
        case ready = "Ready"
        case wrong = "Wrong passcode"
    }
        
    let service = SingleKeyServiceImplementation()
    let router = WalletCreationTypeRouterImplementation()
    
    var address: String?
    var HDservice: HDWalletService?
    var newWallet: Bool = false
    
    @IBOutlet weak var firstnum:UIView!
    @IBOutlet weak var secondNum:UIView!
    @IBOutlet weak var thirdNum:UIView!
    @IBOutlet weak var fourthNum:UIView!
    
    @IBOutlet var btns:[UIButton]!
    
    
    var numsIcons: [UIView]?


    
    var passcode: String = ""
    var repeatedPasscode: String = ""
    var status: passcodeStatus = .new
    
    var passcodeItems: [KeychainPasswordItem] = []
    
    @IBOutlet weak var navigationBar:UINavigationBar!
    
    @IBOutlet weak var messageLabel:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.shadowImage = UIImage()
        numsIcons = [firstnum, secondNum, thirdNum, fourthNum]
        changePasscodeStatus(.new)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarColor(nil)
    }

    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func changePasscodeStatus(_ newStatus: passcodeStatus) {
        status = newStatus
        messageLabel.text = NSLocalizedString(status.rawValue, comment: "")
        if status == .wrong {
            repeatedPasscode = ""
            changeNumsIcons(0)
        } else if status == .ready {
            createWallet()
        } else if status == .verify {
            changeNumsIcons(0)
        }else if status == .new {
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
            dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
            self.router.exitFromTheScreen()
        }
    }
    
    func changeNumsIcons(_ nums: Int) {
        switch nums {
        case 0:
            for i in 0...(numsIcons?.count)!-1 {
                self.numsIcons![i].unfill()
            }
        case 4:
            for i in 0...nums-1 {
                self.numsIcons![i].fill()
            }
        default:
            for i in 0...nums-1 {
                self.numsIcons![i].fill()
            }
            for i in nums...(numsIcons?.count)!-1 {
                self.numsIcons![i].unfill()
            }
        }
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
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



extension UIView {
    func unfill() {
        backgroundColor = .clear
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.mainColor.cgColor
    }
    
    func fill() {
        layer.borderWidth = 0
        layer.borderColor = nil
        backgroundColor = UIColor.mainColor
    }
}

//
//  PasscodeEnterController.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 25.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit

class PasscodeEnterController: UIViewController {
    
    enum passcodeStatus: String {
        case enter = "Touch ID or Enter Passcode"
        case wrong = "Wrong passcode"
        case ready = "Ready"
    }
    
    @IBOutlet weak var messageLabel: UILabel!
    var rightPasscode = UserDefaults.standard.string(forKey: "Passcode")! // we already shure that it exists
    var passcode: String = ""
    var status: passcodeStatus = .enter
    
    @IBOutlet weak var firstNum: UIImageView!
    @IBOutlet weak var secondNum: UIImageView!
    @IBOutlet weak var thirdNum: UIImageView!
    @IBOutlet weak var fourthNum: UIImageView!
    
    var numsIcons: [UIImageView]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changePasscodeStatus(.enter)
        numsIcons = [firstNum, secondNum, thirdNum, fourthNum]
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
    
    func enterWallet() {
        
        self.performSegue(withIdentifier: "showProcessFromPinCode", sender: self)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        DefaultTokensServiceImplementation().downloadAllAvailableTokensIfNeeded {
            
            let tabController = storyboard.instantiateViewController(withIdentifier: "MainTabController")
            let tabNavigation = UINavigationController(rootViewController: tabController)
            
            let appDelegate: AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            appDelegate.window?.rootViewController = tabNavigation
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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    @IBAction func numberPressed(_ sender: enterPinCodeNumberButton) {
        let number = sender.currentTitle!
        
        if status == .enter {
            passcode += number
            changeNumsIcons(passcode.count)
            if passcode.count == 4 {
                let newStatus: passcodeStatus = passcode == rightPasscode ? .ready : .wrong
                changePasscodeStatus(newStatus)
            }
        } else if status == .wrong {
            changePasscodeStatus(.enter)
            passcode += number
            changeNumsIcons(passcode.count)
        }
        
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        if passcode != "" {
            passcode.removeLast()
            changeNumsIcons(passcode.count)
        }
    }
    
    
}

class enterPinCodeNumberButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.layer.bounds.width/2
    }
}

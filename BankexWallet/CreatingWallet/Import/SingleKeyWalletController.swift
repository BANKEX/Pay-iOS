//
//  SingleKeyWalletController.swift
//  BankexWallet
//
//  Created by Vladislav on 18.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import Amplitude_iOS
import web3swift
import GrowingTextView

class SingleKeyWalletController: BaseViewController,UITextFieldDelegate,ScreenWithContentProtocol,QRReaderVCDelegate {
    
    
    
    enum State {
        case notAvailable,available
    }
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var clearButton:UIButton!
    @IBOutlet weak var privateKeyTextView:GrowingTextView!
    @IBOutlet weak var nameWalletTextField:UITextField!
    @IBOutlet weak var separator1:UIView!
    @IBOutlet weak var separator2:UIView!
    @IBOutlet weak var importButton:UIButton!
    @IBOutlet weak var pasteButton:PasteButton!
    @IBOutlet weak var qrButton:QRButton!
    
    
    //MARK: - Properties
    
    
    let service = SingleKeyServiceImplementation()
    let router = WalletCreationTypeRouterImplementation()
    
    var state:State = .notAvailable {
        didSet {
            if state == .notAvailable {
                clearButton.isHidden = true
                importButton.isEnabled = false
                importButton.backgroundColor = UIColor.lightBlue
                privateKeyTextView.returnKeyType = .next
            }else {
                clearButton.isHidden = false
                importButton.isEnabled = true
                importButton.backgroundColor = UIColor.mainColor
                privateKeyTextView.returnKeyType = .done
            }
        }
    }

    
    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        configure()
        state = .notAvailable
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    //MARK: - Methods
    
    func clearTextFields() {
        nameWalletTextField.text = ""
        view.endEditing(true)
    }
    
    func configure() {
        privateKeyTextView.delegate = self
        nameWalletTextField.delegate = self
        nameWalletTextField.autocorrectionType = .no
        privateKeyTextView.placeholder = NSLocalizedString("Enter your private key", comment: "")
        privateKeyTextView.placeholderColor = UIColor.setColorForTextViewPlaceholder()
        privateKeyTextView.trimWhiteSpaceWhenEndEditing = false
        privateKeyTextView.autocorrectionType = .no
        privateKeyTextView.autocapitalizationType = .none
    }
    
   
    
    //MARK: - IBActions
    @IBAction func clearTextView(_ sender:Any) {
        privateKeyTextView.text = ""
        state = .notAvailable
    }
    
    
    
    
    @IBAction func createPrivateKeyWallet(_ sender:Any) {
        if UIDevice.isIpad {
            if !UserDefaults.standard.bool(forKey: "passcodeExists") {
                presentPasscodeIpad()
            }else {
                service.createNewSingleAddressWallet(with: nameWalletTextField.text, fromText: privateKeyTextView.text, password: nil) { (error) in
                    if let _ = error {
                        self.showCreationAlert()
                    }
                    Amplitude.instance().logEvent("Wallet Imported")
                    self.performSegue(withIdentifier: "showProcessFromImportSecretKey", sender: self)
                }
            }
        }else {
            service.createNewSingleAddressWallet(with: nameWalletTextField.text, fromText: privateKeyTextView.text, password: nil) { (error) in
                if let _ = error {
                    self.showCreationAlert()
                }
                Amplitude.instance().logEvent("Wallet Imported")
                if !UserDefaults.standard.bool(forKey: "passcodeExists") {
                    self.performSegue(withIdentifier: "goToPinFromImportSingleKey", sender: self)
                } else {
                    self.performSegue(withIdentifier: "showProcessFromImportSecretKey", sender: self)
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PasscodeLockController {
            destinationViewController.newWallet = false
        }
        if let vc = segue.destination as? SendingInProcessViewController {
            vc.fromEnterScreen = true
        }
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done && importButton.isEnabled {
            createPrivateKeyWallet(self)
        }else if textField.returnKeyType == .next {
            privateKeyTextView.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        separator2.backgroundColor = UIColor.mainColor
        textField.returnKeyType = importButton.isEnabled ? .done : .next
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        separator2.backgroundColor = UIColor.separatorColor
    }
    
    
    @IBAction func scanDidTapped(_ scan: UIButton) {
        let qrReaderVC = QRReaderVC()
        qrReaderVC.delegate = self
        self.present(qrReaderVC, animated: true)
    }
    
    @IBAction func bufferDidTapped() {
        if let string = UIPasteboard.general.string  {
            privateKeyTextView.text = string
            state = .available
        }
    }
    
    func presentPasscodeIpad() {
        let passcodeVC = CreateVC(byName: "PasscodeIpadVC") as! PasscodeIpadVC
        passcodeVC.modalPresentationStyle = .formSheet
        passcodeVC.delegate = self
        passcodeVC.preferredContentSize = CGSize(width: 320, height: 600)
        present(passcodeVC, animated: true, completion: nil)
    }
    
    func didScan(_ result: String) {
        if let parsed = Web3.EIP67CodeParser.parse(result) {
            privateKeyTextView.text = parsed.address.address
        }else {
            privateKeyTextView.text = result
        }
        privateKeyTextView.becomeFirstResponder()
        state = .available
    }
    
}

extension SingleKeyWalletController:PasscodeIpadVCDelegate {
    func didCreate() {
        service.createNewSingleAddressWallet(with: nameWalletTextField.text, fromText: privateKeyTextView.text, password: nil) { (error) in
            if let _ = error {
                self.showCreationAlert()
            }
            Amplitude.instance().logEvent("Wallet Imported")
            self.router.exitFromTheScreeniPad()
        }
    }
}


extension SingleKeyWalletController:GrowingTextViewDelegate  {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.returnKeyType = importButton.isEnabled ? .done : .next
        separator1.backgroundColor = UIColor.mainColor
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 {
            state = .available
            if textView == privateKeyTextView && textView.text.isEmpty {
                if text.utf16.count == 0 {
                    return false
                }
            }
            return true
        }else {
            state = .notAvailable
            textView.text = ""
            return false
        }
    }
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        separator1.backgroundColor = UIColor.separatorColor
    }
}



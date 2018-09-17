//
//  SingleKeyWalletController.swift
//  BankexWallet
//
//  Created by Vladislav on 18.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import QRCodeReader
import Amplitude_iOS
import web3swift

class SingleKeyWalletController: BaseViewController,UITextFieldDelegate,ScreenWithContentProtocol,QRReaderVCDelegate {
    
    
    
    enum State {
        case notAvailable,available
    }
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var clearButton:UIButton!
    @IBOutlet weak var privateKeyTextView:UITextView!
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
                importButton.backgroundColor = WalletColors.disableColor
                privateKeyTextView.returnKeyType = .next
            }else {
                clearButton.isHidden = false
                importButton.isEnabled = true
                importButton.backgroundColor = WalletColors.mainColor
                privateKeyTextView.returnKeyType = .done
            }
        }
    }

    
    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        state = .notAvailable
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let text = privateKeyTextView.text {
            if text == "\n" {
                privateKeyTextView.applyPlaceHolderText(with: "Enter your passphrase")
            }
        }
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
        privateKeyTextView.contentInset.bottom = 10.0
        privateKeyTextView.applyPlaceHolderText(with: NSLocalizedString("Enter your private key", comment: ""))
        privateKeyTextView.autocorrectionType = .no
        privateKeyTextView.autocapitalizationType = .none
    }
    
   
    
    //MARK: - IBActions
    @IBAction func clearTextView(_ sender:Any) {
        privateKeyTextView.applyPlaceHolderText(with: NSLocalizedString("Enter your private key", comment: ""))
        privateKeyTextView.moveCursorToStart()
        state = .notAvailable
    }
    
    @IBAction func createPrivateKeyWallet(_ sender:Any) {
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
            privateKeyTextView.applyNotHolder()
            privateKeyTextView.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        separator2.backgroundColor = WalletColors.mainColor
        textField.returnKeyType = importButton.isEnabled ? .done : .next
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        separator2.backgroundColor = WalletColors.separatorColor
    }
    
    
    @IBAction func scanDidTapped(_ scan: UIButton) {
        let qrReaderVC = QRReaderVC()
        qrReaderVC.delegate = self
        self.present(qrReaderVC, animated: true)
    }
    
    @IBAction func bufferDidTapped() {
        if let string = UIPasteboard.general.string  {
            privateKeyTextView.text = string
            privateKeyTextView.textColor = .black
            state = .available
        }
    }
    
    func didScan(_ result: String) {
        privateKeyTextView.applyNotHolder()
        
        if let parsed = Web3.EIP67CodeParser.parse(result) {
            privateKeyTextView.text = parsed.address.address
        }else {
            privateKeyTextView.text = result
        }
        privateKeyTextView.becomeFirstResponder()
        state = .available
    }
    
}




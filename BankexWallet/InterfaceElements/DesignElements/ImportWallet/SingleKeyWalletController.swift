//
//  SingleKeyWalletController.swift
//  BankexWallet
//
//  Created by Vladislav on 18.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import QRCodeReader

class SingleKeyWalletController: UIViewController,UITextFieldDelegate,ScreenWithContentProtocol {
    
    
    
    
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var clearButton:UIButton!
    @IBOutlet weak var privateKeyTextView:UITextView!
    @IBOutlet weak var singleKeyView:SingleKeyView!
    @IBOutlet weak var separator1:UIView!
    @IBOutlet weak var separator2:UIView!
    @IBOutlet weak var importButton:UIButton!
    
    
    //MARK: - Properties
    
    var privateKeyView = SingleKeyView()
    var service = SingleKeyServiceImplementation()
    lazy var readerVC:QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes:[.qr],captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    let router = WalletCreationTypeRouterImplementation()

    
    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        importButton.isEnabled = false
        privateKeyTextView.delegate = self
        singleKeyView.delegate = self
        privateKeyTextView.contentInset.bottom = 10.0
        privateKeyTextView.applyPlaceHolderText(with: "Enter your private key")
        clearButton.isHidden = true
        privateKeyTextView.autocorrectionType = .no
        privateKeyTextView.autocapitalizationType = .none
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    //MARK: - Methods
    
    func clearTextFields() {
        singleKeyView.nameWalletTextField.text = ""
        privateKeyTextView.applyPlaceHolderText(with: "Enter your private key")
        view.endEditing(true)
        updateUI()
    }
    
    func updateUI() {
        if privateKeyTextView.text.utf16.count > 0  {
            clearButton.isHidden = true
            importButton.isEnabled = false
            importButton.backgroundColor = WalletColors.defaultGreyText.color()
        }
    }
    
    func showCreationAlert() {
        let alertViewController = UIAlertController(title: "Error", message: "Couldn't add key", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertViewController, animated: true)
    }
    
    //MARK: - IBActions
    @IBAction func clearTextView(_ sender:Any) {
        privateKeyTextView.applyPlaceHolderText(with: "Enter your private key")
        clearButton.isHidden = true
        privateKeyTextView.moveCursorToStart()
        importButton.isEnabled = false
        importButton.backgroundColor = importButton.isEnabled ? WalletColors.blueText.color() : WalletColors.defaultGreyText.color()
    }
    
    @IBAction func createPrivateKeyWallet(_ sender:Any) {
        service.createNewSingleAddressWallet(with: singleKeyView.nameWalletTextField.text, fromText: privateKeyTextView.text, password: nil) { (error) in
            if let _ = error {
                self.showCreationAlert()
            }
            self.router.exitFromTheScreen()
        }
        
    }
    
    
    
    
    
}




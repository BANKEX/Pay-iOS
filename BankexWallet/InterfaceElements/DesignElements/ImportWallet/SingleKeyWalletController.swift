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
    
    //MARK: - IBActions
    @IBAction func clearTextView(_ sender:Any) {
        privateKeyTextView.applyPlaceHolderText(with: "Enter your private key")
        clearButton.isHidden = true
        privateKeyTextView.moveCursorToStart()
        importButton.isEnabled = false
        importButton.backgroundColor = importButton.isEnabled ? WalletColors.blueText.color() : WalletColors.defaultGreyText.color()
    }
    
    
    
    
    
    
    //MARK: - TextViewDelegate
    
    
    
}




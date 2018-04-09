//
//  SendTokenViewController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina (Agoda) on 4/8/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation

class SendTokenViewController: UIViewController,
UITextFieldDelegate,
QRCodeReaderViewControllerDelegate {

    //MARK: Outlets
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var favNameContainer: UIView!
    
    @IBAction func deleteSelectedFavTapped(_ sender: Any) {
    }
    @IBOutlet weak var selectedFavNameLabel: UILabel!
    
    @IBOutlet weak var enterAddressTextfield: UITextField!
    
    @IBOutlet weak var memoTextfield: UITextField!
    @IBOutlet weak var amountTextfield: UITextField!
    @IBOutlet var textFields: [UITextField]!
    
    @IBOutlet var separators: [UIView]!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet var additionalInputContainerView: UIView!
    
    @IBOutlet weak var insertFromClipboardButton: UIButton!
    
    @IBOutlet weak var tokenSymbolLabel: UILabel!
    
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    // MARK: Actions
    @IBAction func nextButtonTapped(_ sender: Any) {
    }
    @IBAction func switchPasswordVisibility(_ sender: UIButton) {
        passwordTextfield.isSecureTextEntry = !passwordTextfield.isSecureTextEntry
        sender.setImage(passwordTextfield.isSecureTextEntry ? #imageLiteral(resourceName: "Eye open") : #imageLiteral(resourceName: "Eye closed"), for: .normal)
    }
    @IBAction func clearAddressTapped(_ sender: Any) {
        enterAddressTextfield.text = ""
    }
    
    @IBAction func scanQRTapped(_ sender: Any) {
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    @IBAction func addFromFavouritesTapped(_ sender: Any) {
        // TODO: Open favs list
    }
    
    @IBAction func insertFromClipboardTapped(_ sender: Any) {
        enterAddressTextfield.text = UIPasteboard.general.string
    }
    
    // MARK: TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let index = textFields.index(of: textField) ?? 0
        separators[index].backgroundColor = WalletColors.blueText.color()
        textField.textColor = WalletColors.blueText.color()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "")  as NSString
        let futureString = currentText.replacingCharacters(in: range, with: string) as String
        
        switch textField {
        case enterAddressTextfield:
            if  !(amountTextfield.text?.isEmpty ?? true) &&
                !(passwordTextfield.text?.isEmpty ?? true) &&
                !futureString.isEmpty {
                nextButton.isEnabled = true
            }
        case passwordTextfield:
            if !(amountTextfield.text?.isEmpty ?? true) &&
                !(enterAddressTextfield.text?.isEmpty ?? true) &&
                !futureString.isEmpty {
                    nextButton.isEnabled = true
            }
        case amountTextfield:
            if !(passwordTextfield.text?.isEmpty ?? true) &&
                !(enterAddressTextfield.text?.isEmpty ?? true) &&
                !futureString.isEmpty
            {
                nextButton.isEnabled = true
            }
        default:
            nextButton.isEnabled = true
        }
        
        nextButton.backgroundColor = nextButton.isEnabled ? WalletColors.defaultDarkBlueButton.color() : WalletColors.disableButtonBackground.color()
        
        return true
    }
    
    
    // QR:
    // MARK: QR Code scan
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    // MARK: - QRCodeReaderViewController Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        enterAddressTextfield.text = result.value
        dismiss(animated: true, completion: nil)
    }
    

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
}

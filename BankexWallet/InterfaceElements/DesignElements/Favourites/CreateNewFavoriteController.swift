//
//  CreateNewFavoriteController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina (Agoda) on 5/11/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation

protocol CreateNewContact {
    func addContact(with address: String)
}

class CreateNewFavoriteController: UIViewController,
    UITextFieldDelegate,
    QRCodeReaderViewControllerDelegate,
    CreateNewContact,
    FavoriteInputController {

    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var textfields: [UITextField]!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet var separators: [UIView]!
    @IBOutlet weak var addressTextfield: UITextField!
    
    @IBOutlet weak var deleteContactButton: UIButton!
    
    // MARK: Inputs
    var selectedFavoriteName: String?
    var selectedFavoriteAddress: String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nameTextfield.text = selectedFavoriteName
        addressTextfield.text = selectedFavoriteAddress
        deleteContactButton.isHidden = !favoritesService.contains(address: addressTextfield.text ?? "")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollViewHeightConstraint.constant = -76 // 76 is top part
        
        if #available(iOS 11.0, *) {
            scrollViewHeightConstraint.constant -= (view.safeAreaInsets.top + view.safeAreaInsets.bottom)
        }
    }
    
    @IBAction func hideKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    let favoritesService: RecipientsAddressesService = RecipientsAddressesServiceImplementation()
    @IBAction func saveContact(_ sender: Any) {
        guard let address = addressTextfield.text,
            let name = nameTextfield.text,
            !favoritesService.contains(address: address) else {
                return
        }
        favoritesService.store(address: address, with: name)
        navigationController?.popToRootViewController(animated: true)
    }
    
    func addContact(with address: String) {
        addressTextfield.text = address
    }
    
    @IBAction func deleteContact(_ sender: Any) {
        guard favoritesService.contains(address: addressTextfield.text ?? "") else {
            return
        }
        let alert = UIAlertController(title: "Are you sure?", message: "You're going to remove this favorite contact.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (Target) in
            self.favoritesService.delete(with: self.addressTextfield.text ?? "")
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func scanQRAddress(_ sender: Any) {
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
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
        addressTextfield.text = result.value.trimmingCharacters(in: CharacterSet.whitespaces)
        dismiss(animated: true, completion: nil)
    }
    
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }

    // MARK: Textfield delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let index = textfields.index(of: textField) ?? 0
        separators[index].backgroundColor = WalletColors.blueText.color()
        textField.textColor = WalletColors.blueText.color()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let index = textfields.index(of: textField) ?? 0
        separators[index].backgroundColor = WalletColors.greySeparator.color()
        textField.textColor = WalletColors.defaultText.color()
        
        return true
    }
}

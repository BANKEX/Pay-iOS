//
//  CreateNewFavoriteController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 5/11/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import web3swift

protocol CreateNewContact {
    func addContact(with address: String)
}

class CreateNewFavoriteController: UIViewController,
    UITextFieldDelegate,
    QRCodeReaderViewControllerDelegate,
    CreateNewContact,
    FavoriteInputController {

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var textfields: [UITextField]!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet var separators: [UIView]!
    @IBOutlet weak var addressTextfield: UITextField!
    
    @IBOutlet weak var deleteContactButton: UIButton!
    
    // MARK: Inputs
    var selectedFavoriteName: String?
    var selectedFavoriteAddress: String?
    
    var editingContact: Bool = false //if first creating account

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextfield.text = selectedFavoriteName
        addressTextfield.text = selectedFavoriteAddress
        deleteContactButton.isHidden = !favoritesService.contains(address: addressTextfield.text ?? "")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
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
        
        guard let name = nameTextfield.text, !name.isEmpty else {
            nameTextfield.attributedPlaceholder = NSAttributedString(string: "Please, enter the name of the contact", attributes: [NSAttributedStringKey.foregroundColor: WalletColors.defaultGreyText.color(), NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 12)])
            UIView.animate(withDuration: 0.5, animations: {
                self.nameTextfield.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { (_) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.nameTextfield.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            }
            return
        }
        guard let address = addressTextfield.text, !address.isEmpty else {
            addressTextfield.attributedPlaceholder = NSAttributedString(string: "Please, enter the address of the contact", attributes: [NSAttributedStringKey.foregroundColor: WalletColors.defaultGreyText.color(), NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 12)])
            UIView.animate(withDuration: 0.5, animations: {
                self.addressTextfield.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { (_) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.addressTextfield.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            }
            return
        }
        guard let ethAddress = EthereumAddress(addressTextfield.text ?? "") else {
            UIView.animate(withDuration: 0.5, animations: {
                self.addressTextfield.textColor = WalletColors.redText.color()
                self.addressTextfield.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { (_) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.addressTextfield.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.addressTextfield.textColor = WalletColors.defaultText.color()
                })
            }
            return
        }
        favoritesService.store(address: address, with: name, isEditing: editingContact) { (error) in
            if error?.localizedDescription == "Address already exists in the database" {
                self.addressTextfield.text = ""
                self.addressTextfield.attributedPlaceholder = NSAttributedString(string: "Address already exists in the database", attributes: [NSAttributedStringKey.foregroundColor: WalletColors.defaultGreyText.color(), NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 12)])
                UIView.animate(withDuration: 0.5, animations: {
                    self.addressTextfield.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }) { (_) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.addressTextfield.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    })
                }
                return
            } else if error?.localizedDescription == "Name already exists in the database" {
                self.nameTextfield.text = ""
                self.nameTextfield.attributedPlaceholder = NSAttributedString(string: "Name already exists in the database", attributes: [NSAttributedStringKey.foregroundColor: WalletColors.defaultGreyText.color(), NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 12)])
                UIView.animate(withDuration: 0.5, animations: {
                    self.nameTextfield.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }) { (_) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.nameTextfield.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    })
                }
                return
            } else if error != nil {
                return
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }
        
        
        
    }
    
    func addContact(with address: String) {
        selectedFavoriteAddress = address
    }
    
    @IBAction func deleteContact(_ sender: Any) {
        guard favoritesService.contains(address: addressTextfield.text ?? "") else {
            return
        }
        let alert = UIAlertController(title: "Are you sure?", message: "You're going to remove this favorite contact.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (Target) in
            self.favoritesService.delete(with: self.addressTextfield.text ?? "") {
                
            }
            self.navigationController?.popViewController(animated: true)
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
        let value = result.value
        
        if let parsed = Web3.EIP67CodeParser.parse(value) {
            addressTextfield.text = parsed.address.address
        }
        else  {
            
            if let address = EthereumAddress(value) {
                addressTextfield.text = value
            }
        }
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveContact(self)
        return true
    }
    
    // MARK: Keyboard
    @objc func keyboardDidHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
        
        UIView.animate(withDuration: duration,
                       delay: TimeInterval(0),
                       options: animationCurve,
                       animations: {
                        self.scrollView.contentInset = UIEdgeInsets.zero
                        self.scrollView.contentOffset = CGPoint.zero
                        
        },
                       completion: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let endFrameHeight = endFrame?.size.height ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            let textField = textfields.first {$0.isFirstResponder}
            let textFieldFrameY = (textField?.frame.maxY ?? 0) + 50
            var  newOffset: CGFloat = 0
            if textFieldFrameY > view.frame.maxY - endFrameHeight && textField != nil {
                newOffset = textFieldFrameY - (view.frame.maxY - endFrameHeight)
            }
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            if endFrameY >= UIScreen.main.bounds.size.height {
                                self.scrollView.contentInset = UIEdgeInsets.zero
                            } else {
                                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, endFrame?.size.height ?? 0.0, 0)
                            }
                            self.scrollView.contentOffset = CGPoint(x: 0, y: newOffset)
                            
            },
                           completion: nil)
        }
    }
}

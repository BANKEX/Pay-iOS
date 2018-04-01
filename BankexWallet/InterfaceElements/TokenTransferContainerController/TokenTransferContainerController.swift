//
//  TokenTransferContainerController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/6/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift
import AVFoundation
import QRCodeReader
import BigInt
import LocalAuthentication


class TokenTransferContainerController: UIViewController,
UIScrollViewDelegate,
AddressSelection,
QRCodeReaderViewControllerDelegate {
    
    func didSelect(address: String) {
        destinationTextfield.text = address
        addressesListContainer.isHidden = true
    }
    

    // MARK: Services
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    var sendEthService: SendEthService!
    var utilsService: UtilTransactionsService!
    
    // MARK: Outlets
    
    @IBOutlet weak var addressesListContainer: UIView!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var ethAmountTextfield: UITextField!
    @IBOutlet weak var destinationTextfield: UITextField!    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let selectedAddress = keysService.selectedAddress() else {
            return
        }
        addressLabel.text = "Address: " + selectedAddress
    }
    
    
    var selectedTransaction: SendEthTransaction?
    let tokensService = CustomERC20TokensServiceImplementation()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sendEthService = tokensService.selectedERC20Token().address.isEmpty ?
            SendEthServiceImplementation() :
            ERC20TokenContractMethodsServiceImplementation()
        
        utilsService = tokensService.selectedERC20Token().address.isEmpty ? UtilTransactionsServiceImplementation() :
            CustomTokenUtilsServiceImplementation()
        updateBalance()

        guard let selectedTransaction = selectedTransaction else {
            return
        }
        destinationTextfield.text = selectedTransaction.to
        
        guard let amount = selectedTransaction.amount?.components(separatedBy: " ").first,
            let uintAmount = UInt(amount)
             else {
                return
        }
        //TODO: Check how it works now with ether
        ethAmountTextfield.text = amount
    }
    
    // MARK: 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addressesList" {
            let controller = segue.destination as? SavedAddressesList
            controller?.selectionAddressDelegate = self
        }
    }
    
    // MARK: ScrollView
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    // MARK: Confirmation Process
    
    func showConfirmation(forSending amount: String,
                          destinationAddress:String,
                          transaction: TransactionIntermediate) {
        let alertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to send \(amount) \(tokensService.selectedERC20Token().symbol). to \(destinationAddress)", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Sure", style: .default, handler: { (_) in
            self.useFaceIdToAuth(transaction: transaction)
        }))
        alertController.addAction(UIAlertAction(title: "Let me think", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    func useFaceIdToAuth(transaction: TransactionIntermediate) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] (success, authenticationError) in
                
                DispatchQueue.main.async {
                    if success {
                        self.confirm(transaction: transaction)
                    } else {
                        // error
                    }
                }
            }
        } else {
            // no biometry
        }
    }
    
    
    let addressesService: RecipientsAddressesService = RecipientsAddressesServiceImplementation()
    
    func confirm(transaction: TransactionIntermediate) {
        let token = tokensService.selectedERC20Token()
        let transactionModel = ETHTransactionModel(from: keysService.selectedAddress() ?? "",
                                                   to: destinationTextfield.text ?? "",
                                                   amount: (ethAmountTextfield.text ?? "") + " " + token.symbol,
                                                   date: Date(),
                                                   token: token,
                                                   key: keysService.selectedKey()!)
        sendEthService.send(transactionModel:transactionModel,
                            transaction: transaction) { (result) in
            switch result {
            case .Success(let response):
                let alertController = UIAlertController(title: "Succeed", message: "\(response)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                    self.showSaveRecipientSuggestion(addressToSave: self.destinationTextfield.text)
                    self.destinationTextfield.text = nil
                    self.ethAmountTextfield.text = nil
                }))
                self.present(alertController, animated: true, completion: nil)
                self.updateBalance()
            case .Error(let error):
                print("\(error)")
            }
        }
    }
    
    func showSaveRecipientSuggestion(addressToSave: String?) {
        guard let address = addressToSave,
            !addressesService.contains(address: address) else {
            return
        }
        
        let alertController = UIAlertController(title: "Save address", message: "Do you want to save \(address) ?", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Contact Name"
        }
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            guard let text = alertController.textFields?[0].text, !text.isEmpty else {
                return
            }
            self.addressesService.store(address: address, with: text)
        }))
        alertController.addAction(UIAlertAction(title: "No need", style: .cancel, handler: { (_) in
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Balance
    func updateBalance() {
        guard let selectedAddress = keysService.selectedAddress() else {
            return
        }
        utilsService.getBalance(for: tokensService.selectedERC20Token().address, address: selectedAddress) { (result) in
            switch result {
            case .Success(let response):
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                let formattedAmount = Web3.Utils.formatToEthereumUnits(response, toUnits: .eth, decimals: 4)
                self.currentBalanceLabel.text = "Amount: " + formattedAmount!
            case .Error(let error):
                print("\(error)")
            }
        }
    }
    
    // MARK: Actions
    @IBAction func scanQRCode(_ sender: Any) {
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    @IBAction func openSavedAddressesList(_ sender: Any) {
        addressesListContainer.isHidden = false
    }
    
    @IBAction func openDefaultAddressInput(_ sender: Any) {
        addressesListContainer.isHidden = true
    }
    
    @IBAction func endEditingTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func sendTransaction(_ sender: Any) {
        guard let amount = ethAmountTextfield.text,
            let destinationAddress = destinationTextfield.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                return
        }
        sendEthService.prepareTransactionForSending(destinationAddressString: destinationAddress, amountString: amount) { (result) in
            switch result {
            case .Success(let transaction):
                self.showConfirmation(forSending: amount, destinationAddress: destinationAddress, transaction: transaction)
            case .Error(let error):
                print("\(error)")
            }
        }
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
        destinationTextfield.text = result.value
        dismiss(animated: true, completion: nil)
    }
    
    //This is an optional delegate method, that allows you to be notified when the user switches the cameraName
    //By pressing on the switch camera button
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
//        if let cameraName = newCaptureDevice.device.localizedName {
//            print("Switching capturing to: \(cameraName)")
//        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
}

//
//  SendTokenViewController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/8/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import AVFoundation
import web3swift
import Popover


class SendTokenViewController: BaseViewController,InfoViewDelegate,
Retriable,UITextFieldDelegate {
    func deleteButtonTapped() {
        //
    }
    
    
    //MARK: Outlets
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var selectedFavNameLabel: UILabel!
    @IBOutlet weak var enterAddressTextfield: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var amountTextfield: UITextField!
    @IBOutlet weak var insertFromClipboardButton: UIButton!
    @IBOutlet weak var tokenSymbolLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var tokenImageView: UIImageView!
    @IBOutlet weak var infoView:InfoView!
    @IBOutlet weak var contactsButton:UIButton!
    @IBOutlet weak var wrongAddrLbl:UILabel!
    @IBOutlet weak var topContrStack:NSLayoutConstraint!
    @IBOutlet weak var notEnoughSumLbl:UILabel!
    @IBOutlet var textFields:[UITextField]!
    
    
    
    lazy var symbolTFLabel:UILabel = {
        let label = UILabel()
        label.textColor = WalletColors.blackColor
        label.font = UIFont.systemFont(ofSize: 17.0)
        return label
    }()
    var button: UIButton!
    var initialHeight:CGFloat = 0
    var errorMessage: String?
    let conversionService = FiatServiceImplementation.service
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
        .arrowSize(CGSize(width: 29, height: 16)),
        .cornerRadius(8.0)
    ]
    // MARK: Services
    var sendEthService: SendEthService!
    let tokensService = CustomERC20TokensServiceImplementation()
    var utilsService: UtilTransactionsService!
    var tokensTableViewManager = TokensTableViewManager()
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    var transaction:TransactionIntermediate?

    // MARK: Inputs
    var selectedToken:ERC20TokenModel {
        return tokensService.selectedERC20Token()
    }
    var isEthToken:Bool {
        return selectedToken.address.isEmpty
    }
    var isCorrectAddress:Bool {
        guard let addr = enterAddressTextfield.text else { return false }
        guard let _ = EthereumAddress(addr) else { return false }
        return true
    }
    
    var isCorrectAmount:Bool {
        guard let _ = Float((amountTextfield.text ?? "")) else { return false }
        guard let amountString = amountTextfield.text,let amount = Float(amountString) else { return false }
        guard let currentBalance = currentBalance, let curBal = Float(currentBalance) else { return false }
        return amount <= curBal
    }
    
    var currentBalance:String?
    // MARK: Lifecycle
    @IBAction func back(segue:UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        layoutSymbolLabel()
        topContrStack.constant = 16.0
        wrongAddrLbl.alpha = 0
        notEnoughSumLbl.alpha = 0
        initialHeight = infoView.bounds.height
        infoView.delegate = self
        setupContactsButton()
        configurePlaceholder()
        nextButton.isEnabled = false
        nextButton.backgroundColor = WalletColors.disableColor
        setupNotifications()
        updateTopLayout()
    }
    
    
    
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func configurePlaceholder() {
        let attrString = NSAttributedString(string: NSLocalizedString("EnterAddr", comment: ""), attributes: [NSAttributedStringKey.foregroundColor:WalletColors.clipboardColor])
        let attrStringAmount = NSAttributedString(string: "0", attributes: [NSAttributedStringKey.foregroundColor:WalletColors.clipboardColor])
        enterAddressTextfield.attributedPlaceholder = attrString
        amountTextfield.attributedPlaceholder = attrStringAmount
    }
    
    private func setupContactsButton() {
        contactsButton.layer.cornerRadius = 8.0
        contactsButton.layer.borderWidth = 2.0
        contactsButton.layer.borderColor = WalletColors.mainColor.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        UIApplication.shared.statusBarView?.backgroundColor = WalletColors.mainColor
        UIApplication.shared.statusBarStyle = .lightContent
        updateUI()
//        handleErrorMessage()
    }
    
    
    func updateUI() {
        enterAddressTextfield.text = Mediator.contactAddr ?? enterAddressTextfield.text
        if isEthToken {
            infoView.state = .Eth
        }else {
            infoView.state = .Token
        }
        infoView.nameTokenLabel.text = selectedToken.symbol.uppercased()
        if let currentWallet = keysService.selectedWallet() {
            infoView.nameWallet.text = currentWallet.name
            infoView.addrWallet.text = currentWallet.address.formattedAddrToken(number: 10)
        }
        if let currentBalance = currentBalance {
            infoView.balanceLabel.text = currentBalance
        }else {
            //GetBalance
            updateBalance()
        }
        
        infoView.tokenNameLabel?.text = selectedToken.name
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        view.endEditing(true)
    }
    
    
    

    
    //MARK: - Helpers
    
    
    func updateBalance() {
        utilsService = selectedToken.address.isEmpty ? UtilTransactionsServiceImplementation() :
            CustomTokenUtilsServiceImplementation()
        guard let selectedAddress = keysService.selectedAddress() else {
            return
        }
        utilsService.getBalance(for: selectedToken.address, address: selectedAddress) { (result) in
            switch result {
            case .Success(let response):
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                DispatchQueue.global(qos: .userInitiated).async {
                    let formattedAmount = Web3.Utils.formatToEthereumUnits(response,
                                                                           toUnits: .eth,
                                                                           decimals: 8,
                                                                           fallbackToScientific: true)
                    DispatchQueue.main.async {
                        self.infoView.balanceLabel.text = formattedAmount!
                        self.currentBalance = formattedAmount!
                    }
                }
            case .Error(let error):
                self.infoView.balanceLabel.text = "..."
                print("\(error)")
            }
        }
    }
    
    func updateTopLayout() {
        // Do any additional setup after loading the view.
        sendEthService = isEthToken ? SendEthServiceImplementation() : ERC20TokenContractMethodsServiceImplementation()
    }
    
    private func setupTextFields() {
        amountTextfield.placeholder = "0"
        enterAddressTextfield.autocorrectionType = .no
        amountTextfield.autocorrectionType = .no
    }
    
    private func layoutSymbolLabel() {
        let token = tokensService.selectedERC20Token()
        symbolTFLabel.text = token.symbol.uppercased()
        let xOffset = amountTextfield.frame.origin.x + amountTextfield.placeholder!.size(amountTextfield.font!).width
        symbolTFLabel.frame = CGRect(x: xOffset, y: -1, width: 60.0, height: amountTextfield.bounds.height)
        amountTextfield.addSubview(symbolTFLabel)
    }

    

    
    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeToken.notificationName(), object: nil, queue: nil) { (_) in
            self.updateTopLayout()
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    func handleErrorMessage() {
        if let message = errorMessage {
            errorMessage = nil
            switch message {
            case "invalidAddress":
                enterAddressTextfield.textColor = WalletColors.errorColor
                
            case "insufficient funds for gas * price + value":
                print("well")
                amountTextfield.textColor = WalletColors.errorColor
                
            default:
                break
            }
        }
    }
    
    
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    
    var sendingProcess: SendingResultInformation?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChooseFeeViewController,let amount = amountTextfield.text {
            vc.selectedToken = self.selectedToken
            vc.currentBalance = self.currentBalance
            vc.sendEthService = self.sendEthService
            let destinationAddress = enterAddressTextfield.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            vc.destinationAddress = destinationAddress
            vc.transaction = self.transaction
            vc.amount = amount
        } else if let errorVC = segue.destination as? SendingErrorViewController {
            guard let error = sender as? String else { return }
            errorVC.error = error
        }else if let listVC = segue.destination as? ListContactsViewController {
            listVC.fromSendScreen = true
            listVC.delegate = self
            UIApplication.shared.statusBarStyle = .default
        }
        
        guard segue.identifier == "showSending",
            let confirmation = segue.destination as? SendingResultInformation, let vc = segue.destination as? SendingInProcessViewController else {
                return
        }
        sendingProcess =  confirmation
        vc.textToShow = NSLocalizedString("Preparing transaction", comment: "")
        
        
    }
    
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard let amount = amountTextfield.text,
            let destinationAddress = enterAddressTextfield.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                return
        }
        
        performSegue(withIdentifier: "showSending", sender: nil)
        sendEthService.prepareTransactionForSending(destinationAddressString: destinationAddress, amountString: amount) { (result) in
            switch result {
            case .Success(let transaction):
                self.transaction = transaction
                //self.showConfirmation(forSending: amount, destinationAddress: destinationAddress, transaction: transaction)
                let info = ["amount": amount, "destinationAddress": destinationAddress, "transaction": transaction] as [String : Any]
                self.performSegue(withIdentifier: "ShowChooseFee", sender: info)
            case .Error(let error):
                var textToSend = ""
                if let error = error as? SendEthErrors {
                    switch error {
                    case .invalidDestinationAddress:
                        textToSend = "invalidAddress"
                    default:
                        break
                    }
                }
                self.performSegue(withIdentifier: "showError", sender: textToSend)
                print("\(error)")
            }
        }
    }
    
    @IBAction func scanQRTapped(_ sender: Any) {
        let qrReaderVC = QRReaderVC()
        qrReaderVC.delegate = self
        self.present(qrReaderVC, animated: true)
    }
    
    
    @IBAction func addFromFavouritesTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "contactFav", sender: nil)
    }
    
    @IBAction func insertFromClipboardTapped(_ sender: Any) {
        guard let pasteStr = UIPasteboard.general.string else { return }
        enterAddressTextfield.text = pasteStr
        enterAddressTextfield.becomeFirstResponder()
    }
    
    
    
    // MARK: Confirmation
    //    var amountToSend: String?
    //    var destinationAddressToSend: String?
    //    var transactionToSend: TransactionIntermediate?
    func showConfirmation(forSending amount: String,
                          destinationAddress:String,
                          transaction: TransactionIntermediate) {
        sendingProcess?.transactionCanProceed(withAmount: amount, address: destinationAddress, transactionToSend: transaction, password: "BANKEXFOUNDATION")
        //        performSegue(withIdentifier: "showSending", sender: self)
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
                        self.view.frame.origin.y = 0

        },
                       completion: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrameY <= amountTextfield.bottomY && !enterAddressTextfield.isFirstResponder {
                UIView.animate(withDuration: duration,
                               delay: TimeInterval(0),
                               options: animationCurve,
                               animations: {
                                let offSet = self.amountTextfield.bottomY - endFrameY
                                self.view.frame.origin.y = -(offSet + 5.0)
                },
                               completion: nil)
            }
        }
    }
    
    
    // MARK: Retriable
    func retryExisitngTransaction() {
        nextButtonTapped(self)
    }
    
    
}


// MARK: TextField Delegate
extension SendTokenViewController {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.returnKeyType = nextButton.isEnabled ? UIReturnKeyType.done : .next
        textField.textColor = WalletColors.blackColor
        symbolTFLabel.textColor = WalletColors.blackColor
        topContrStack.constant = 16.0
        UIView.animate(withDuration: 0.1) {
            self.wrongAddrLbl.alpha = 0
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.1) {
            self.notEnoughSumLbl.alpha = 0
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "")  as NSString
        let futureString = currentText.replacingCharacters(in: range, with: string) as String
        nextButton.isEnabled = false
        
        switch textField {
        case enterAddressTextfield:
            if  !(amountTextfield.text?.isEmpty ?? true) &&
                !futureString.isEmpty && isCorrectAddress && isCorrectAmount {
                nextButton.isEnabled = (Float((amountTextfield.text ?? "")) != nil)
            }
        case amountTextfield:
            if textField.text!.isEmpty { symbolTFLabel.frame.origin.x = textField.frame.origin.x + textField.placeholder!.size(textField.font!).width }else {
                symbolTFLabel.frame.origin.x = textField.frame.origin.x + futureString.size(textField.font!).width
            }
            if !(enterAddressTextfield.text?.isEmpty ?? true) &&
                !futureString.isEmpty && isCorrectAmount && isCorrectAddress
            {
                nextButton.isEnabled =  (Float((futureString)) != nil)
            }
        default:
            nextButton.isEnabled = false
        }
        
        nextButton.backgroundColor = nextButton.isEnabled ? WalletColors.mainColor : WalletColors.disableColor
        textField.returnKeyType = nextButton.isEnabled ? UIReturnKeyType.done : .next
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done && nextButton.isEnabled {
            nextButtonTapped(self)
        } else if textField.returnKeyType == .next {
            let index = textFields.index(of: textField) ?? 0
            let nextIndex = (index == textFields.count - 1) ? 0 : index + 1
            textFields[nextIndex].becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == enterAddressTextfield {
            guard let addr = enterAddressTextfield.text else {
                return true
            }
            guard let _ = EthereumAddress(addr) else {
                enterAddressTextfield.textColor = WalletColors.errorColor
                topContrStack.constant = 37.0
                UIView.animate(withDuration: 0.1) {
                    self.wrongAddrLbl.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
                nextButton.isEnabled = false
                nextButton.backgroundColor = WalletColors.disableColor
                return true
            }
            if isCorrectAmount {
                nextButton.isEnabled = true
                nextButton.backgroundColor = WalletColors.mainColor
            }
        }else if textField == amountTextfield {
            guard let _ = Float((amountTextfield.text ?? "")) else {
                amountTextfield.textColor = WalletColors.errorColor
                symbolTFLabel.textColor = WalletColors.errorColor
                if amountTextfield.text == "" {
                    symbolTFLabel.textColor = WalletColors.blackColor
                }
                UIView.animate(withDuration: 0.1) {
                    self.notEnoughSumLbl.alpha = 0
                }
                return true
            }
            guard let amountString = amountTextfield.text,let amount = Float(amountString) else { return true }
            guard let currentBalance = Float(infoView.balanceLabel.text!) else { return true }
            if !isCorrectAmount {
                notEnoughSumLbl.text = String(format: NSLocalizedString("Not enough %@ in your wallet", comment: ""), selectedToken.symbol.uppercased())
                amountTextfield.textColor = WalletColors.errorColor
                symbolTFLabel.textColor = WalletColors.errorColor
                UIView.animate(withDuration: 0.1) {
                    self.notEnoughSumLbl.alpha = 1.0
                }
                nextButton.isEnabled = false
                nextButton.backgroundColor = WalletColors.disableColor
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
   
    
    
}

extension SendTokenViewController: QRReaderVCDelegate {
    func didScan(_ result: String) {
        if let parsed = Web3.EIP67CodeParser.parse(result) {
            enterAddressTextfield.text = parsed.address.address
        }else {
            enterAddressTextfield.text = result
        }
    }
}

extension SendTokenViewController: ListContactsViewControllerDelegate {
    func choosenFavoriteContact(contact: FavoriteModel) {
        enterAddressTextfield.text = contact.address
    }
}

//
//  SendTokenViewController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/8/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import web3swift

protocol FavoriteInputController: class {
    var selectedFavoriteName: String? {get set}
    var selectedFavoriteAddress: String? {get set}
    
}


class SendTokenViewController: UIViewController,
    UITextFieldDelegate,
    QRCodeReaderViewControllerDelegate,
    FavoriteInputController,
Retriable {
    
    //MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var additionalDataView: UIView!
    @IBOutlet weak var dataTopEmptyView: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var favNameContainer: UIView!
    
    @IBOutlet weak var selectedFavNameLabel: UILabel!
    
    @IBOutlet weak var enterAddressTextfield: UITextField!
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var currencySymbolLabel: UILabel!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var memoTextfield: UITextField!
    @IBOutlet weak var amountTextfield: UITextField!
    @IBOutlet var textFields: [UITextField]!
    
    @IBOutlet var separators: [UIView]!
    @IBOutlet var additionalInputContainerView: UIView!
    
    @IBOutlet weak var insertFromClipboardButton: UIButton!
    
    @IBOutlet weak var tokenSymbolLabel: UILabel!
    
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var interDataAndBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var additionalDataSeparator: UIView!
    
    var button: UIButton!
    
    // MARK: Services
    var sendEthService: SendEthService!
    let tokensService = CustomERC20TokensServiceImplementation()
    var utilsService: UtilTransactionsService!
    
    // MARK: Inputs
    var selectedFavoriteName: String?
    var selectedFavoriteAddress: String?
    
    
    // MARK: Lifecycle
    @IBAction func back(segue:UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "Home"
        nextButton.isEnabled = false
        nextButton.backgroundColor = WalletColors.disabledGreyButton.color()
        
        addTokensButton()
        //addBackButton()
        
        NotificationCenter.default.addObserver(forName: DataChangeNotifications.didChangeToken.notificationName(), object: nil, queue: nil) { (_) in
            self.updateTopLayout()
            
        }
        updateTopLayout()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterAddressTextfield.text = selectedFavoriteAddress ?? enterAddressTextfield.text
        navigationItem.title = "Send"
        configureWalletInfo()
    }
    
    func updateTopLayout() {
        // Do any additional setup after loading the view.
        sendEthService = tokensService.selectedERC20Token().address.isEmpty ?
            SendEthServiceImplementation() :
            ERC20TokenContractMethodsServiceImplementation()
        utilsService = tokensService.selectedERC20Token().address.isEmpty ? UtilTransactionsServiceImplementation() :
            CustomTokenUtilsServiceImplementation()
        updateBalance()
    }
    
    func configureWalletInfo() {
        let keyService = SingleKeyServiceImplementation()
        addressLabel.text = keyService.selectedWallet()?.address
        walletNameLabel.text = keyService.selectedWallet()?.name
        
    }
    
    func addTokensButton() {
        button = UIButton(type: .system)
        button.setImage(UIImage(named: "Arrow Down"), for: .normal)
        button.setTitle("  ETH", for: .normal)
        button.setTitleColor(WalletColors.blueText.color(), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(showTokensButtonTapped), for: .touchUpInside)
    }
    
    func addBackButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "BackArrow"), for: .normal)
        button.setTitle("  Home", for: .normal)
        button.setTitleColor(WalletColors.blueText.color(), for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    private func configureButton(_ button: UIButton) {
        button.layer.cornerRadius = 14
        button.layer.borderColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
        button.layer.borderWidth = 2
    }
    //TODO: - Create this function
    @objc func showTokensButtonTapped() {
        
    }
    
    @objc func backButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let fixedFrame = view.convert(stackView.frame, from: stackView.superview)
        let size = stackView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        var viewHeight: CGFloat = view.frame.height
        var bottomSpace: CGFloat = 40
        if #available(iOS 11.0, *) {
            viewHeight -= view.safeAreaInsets.bottom
            viewHeight -= view.safeAreaInsets.top
            bottomSpace = 0
            
        }
        let availableSpace = viewHeight - size.height - fixedFrame.minY - 56 - bottomSpace - 25
        interDataAndBottomConstraint.constant = availableSpace < 25 ? 25 : availableSpace
    }
    
    var sendingProcess: SendingResultInformation?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChooseFeeViewController {
            guard let senderDict = sender as? [String: Any] else {return}
            vc.configure(senderDict)
            vc.sendEthService = self.sendEthService
        }
        
        guard segue.identifier == "showSending",
            let confirmation = segue.destination as? SendingResultInformation else {
                return
        }
        sendingProcess =  confirmation
        
    }
    
    // MARK: Actions
    //    @IBAction func showTokensList(_ sender: UIButton) {
    //        guard (CustomERC20TokensServiceImplementation().availableTokensList()?.count ?? 1) > 1 else {
    //            return
    //        }
    //        dimmingView.alpha = 0
    //        containerView.alpha = 0
    //        dimmingView.isHidden = false
    //        containerView.isHidden = false
    //        UIView.animate(withDuration: 0.3) {
    //            self.dimmingView.alpha = 1
    //            self.containerView.alpha = 1
    //        }
    //    }
    //
    //
    //    @IBAction func hideTokensList(_ sender: Any) {
    //        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
    //            self.dimmingView.alpha = 0
    //            self.containerView.alpha = 0
    //        }) { (_) in
    //            self.dimmingView.isHidden = true
    //            self.containerView.isHidden = true
    //        }
    //    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard let amount = amountTextfield.text,
            let destinationAddress = enterAddressTextfield.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                return
        }
        
        performSegue(withIdentifier: "showSending", sender: nil)
        sendEthService.prepareTransactionForSending(destinationAddressString: destinationAddress, amountString: amount) { (result) in
            switch result {
            case .Success(let transaction):
                //self.showConfirmation(forSending: amount, destinationAddress: destinationAddress, transaction: transaction)
                let info = ["amount": amount, "destinationAddress": destinationAddress, "transaction": transaction] as [String : Any]
                self.performSegue(withIdentifier: "ShowChooseFee", sender: info)
            case .Error(let error):
                self.performSegue(withIdentifier: "showError", sender: self)
                print("\(error)")
            }
        }
    }
    
    @IBAction func scanQRTapped(_ sender: Any) {
        readerVC.delegate = self
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    @IBAction func getFreeEthButtonTapped(_ sender: Any) {
        let network = tokensService.networksService.preferredNetwork()
        guard let networkName = network.networkName else { return }
        switch networkName {
        case "rinkeby", "ropsten":
            let urlString = networkName == "rinkeby" ? "https://faucet.rinkeby.io" : "http://faucet.ropsten.be:3001/"
            
            let alertController = UIAlertController(title: "Free Eth", message: "You will be reditected to the \(urlString), where you will receive a further instructions", preferredStyle: UIAlertControllerStyle.alert)
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            let ok = UIAlertAction(title: "Continue", style: .default) { _ in
                guard let url = URL(string: urlString) else { return }
                UIApplication.shared.openURL(url)
            }
            
            alertController.addAction(cancel)
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        default:
            let alertController = UIAlertController(title: "You can not do it", message: "You are on the wrong network now. Please change the network to rinkeby or ropsten to get test Ether.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    
    @IBAction func addFromFavouritesTapped(_ sender: Any) {
        // TODO: Open favs list
    }
    
    @IBAction func insertFromClipboardTapped(_ sender: Any) {
        enterAddressTextfield.text = UIPasteboard.general.string
    }
    
    @IBAction func emptySpaceTapped(_ sender: Any) {
        view.endEditing(false)
    }
    
    // MARK: TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.returnKeyType = nextButton.isEnabled ? UIReturnKeyType.done : .next
        let index = textFields.index(of: textField) ?? 0
        separators[index].backgroundColor = WalletColors.blueText.color()
        textField.textColor = WalletColors.blueText.color()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "")  as NSString
        let futureString = currentText.replacingCharacters(in: range, with: string) as String
        nextButton.isEnabled = false
        
        switch textField {
        case enterAddressTextfield:
            if  !(amountTextfield.text?.isEmpty ?? true) &&
                !futureString.isEmpty {
                nextButton.isEnabled = (Float((amountTextfield.text ?? "")) != nil)
            }
        case amountTextfield:
            if !(enterAddressTextfield.text?.isEmpty ?? true) &&
                !futureString.isEmpty
            {
                nextButton.isEnabled =  (Float((futureString)) != nil)
            }
        default:
            nextButton.isEnabled = false
        }
        
        nextButton.backgroundColor = nextButton.isEnabled ? WalletColors.defaultDarkBlueButton.color() : WalletColors.disableButtonBackground.color()
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
        let index = textFields.index(of: textField) ?? 0
        separators[index].backgroundColor = WalletColors.greySeparator.color()
        textField.textColor = WalletColors.defaultText.color()
        
        
        if textField == amountTextfield {
            guard let _ = Float((amountTextfield.text ?? "")) else {
                let amountIndex = textFields.index(of: amountTextfield) ?? 0
                separators[amountIndex].backgroundColor = WalletColors.errorRed.color()
                amountTextfield.textColor = WalletColors.errorRed.color()
                return true
            }
        }
        return true
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
            enterAddressTextfield.text = parsed.address.address
            if let amount = parsed.amount {
                if tokensService.selectedERC20Token().name != "Ether" {
                    tokensService.updateSelectedToken(to: "")
                }
                amountTextfield.text = Web3.Utils.formatToEthereumUnits(
                    amount,
                    toUnits: .eth,
                    decimals: 4)
            }
        }
        else  {
            if let address = EthereumAddress(value) {
                enterAddressTextfield.text = value
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Balance
    let keysService: SingleKeyService = SingleKeyServiceImplementation()
    func updateBalance() {
        currencySymbolLabel.text = tokensService.selectedERC20Token().symbol.uppercased()
        button.setTitle(tokensService.selectedERC20Token().symbol.uppercased(), for: .normal)
        
        guard let selectedAddress = keysService.selectedAddress() else {
            return
        }
        utilsService.getBalance(for: tokensService.selectedERC20Token().address, address: selectedAddress) { (result) in
            switch result {
            case .Success(let response):
                print("\(response)")
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                let formattedAmount = Web3.Utils.formatToEthereumUnits(response, toUnits: .eth, decimals: 4)
                self.amountLabel.text = formattedAmount
            case .Error(let error):
                print("\(error)")
            }
        }
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
            let textField = textFields.first {$0.isFirstResponder}
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
    
    
    // MARK: Retriable
    func retryExisitngTransaction() {
        nextButtonTapped(self)
    }
}

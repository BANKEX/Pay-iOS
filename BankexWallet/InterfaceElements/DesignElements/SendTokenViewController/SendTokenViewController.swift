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
import Popover

protocol FavoriteInputController: class {
    var selectedFavoriteName: String? {get set}
    var selectedFavoriteAddress: String? {get set}
    
}


class SendTokenViewController: UIViewController,
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
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var interDataAndBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var additionalDataSeparator: UIView!
    @IBOutlet weak var tokenImageView: UIImageView!
    
    @IBOutlet weak var amountInDollarsLabel: UILabel!
    
    var button: UIButton!
    var errorMessage: String?
    var popover: Popover!
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
    
    // MARK: Inputs
    var selectedFavoriteName: String?
    var selectedFavoriteAddress: String?
    
    
    // MARK: Lifecycle
    @IBAction func back(segue:UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Send"
        nextButton.isEnabled = false
        nextButton.backgroundColor = WalletColors.disabledGreyButton.color()
        addTokensButton()
        //addBackButton()
        setupNotifications()
        updateTopLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleErrorMessage()
        enterAddressTextfield.text = selectedFavoriteAddress ?? enterAddressTextfield.text
        configureWalletInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    //MARK: - Helpers
    func configureWalletInfo() {
        let keyService = SingleKeyServiceImplementation()
        addressLabel.text = keyService.selectedWallet()?.address
        walletNameLabel.text = keyService.selectedWallet()?.name
        
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
    
    func addTokensButton() {
        button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Arrow Down"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 80, 0, 0)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        button.setTitle("ETH", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setTitleColor(WalletColors.blueText.color(), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(showTokensButtonTapped), for: .touchUpInside)
    }

    func addBackButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "BackArrow"), for: .normal)
        button.setTitle("  Home", for: .normal)
        button.setTitleColor(WalletColors.blueText.color(), for: .normal)
        //button.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
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
                enterAddressTextfield.textColor = WalletColors.errorRed.color()
                
            case "insufficient funds for gas * price + value":
                print("well")
                amountTextfield.textColor = WalletColors.errorRed.color()
                
            default:
                break
            }
        }
    }
    
    //MARK: - Popover
    @objc func showTokensButtonTapped() {
        popover = Popover(options: self.popoverOptions)
        let tableView = UITableView(frame: CGRect(x: 0, y: 10, width: 100, height: 150), style: .plain)
        tableView.separatorStyle = .none
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 8.0
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 160))
        aView.clipsToBounds = true
        aView.addSubview(tableView)
        let point = CGPoint(x: UIScreen.main.bounds.width - 30, y: 50)
        tokensTableViewManager.delegate = self
        tableView.delegate = tokensTableViewManager
        tableView.dataSource = tokensTableViewManager
        self.popover.show(aView, point: point)

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
        } else if let errorVC = segue.destination as? SendingErrorViewController {
            guard let error = sender as? String else { return }
            errorVC.error = error
        }
        
        guard segue.identifier == "showSending",
            let confirmation = segue.destination as? SendingResultInformation, let vc = segue.destination as? SendingInProcessViewController else {
                return
        }
        sendingProcess =  confirmation
        vc.textToShow = "Preparing transaction"
        
        
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
        readerVC.delegate = self
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
            if let _ = EthereumAddress(value) {
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
        tokenImageView.image = PredefinedTokens(with: tokensService.selectedERC20Token().symbol).image()
        utilsService.getBalance(for: tokensService.selectedERC20Token().address, address: selectedAddress) { (result) in
            switch result {
            case .Success(let response):
                print("\(response)")
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                let formattedAmount = Web3.Utils.formatToEthereumUnits(response, toUnits: .eth, decimals: 4)
                self.amountLabel.text = formattedAmount
                let conversionRate = self.conversionService.currentConversionRate(for: self.tokensService.selectedERC20Token().symbol.uppercased())
                let convertedAmount = conversionRate == 0.0 ? "No data from CryptoCompare" : "$\(conversionRate * Double(formattedAmount!)!) at the rate of CryptoCompare"
                self.amountInDollarsLabel.text = convertedAmount
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

//MARK: - Popover Delegate
extension SendTokenViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

//MARK: - Choose Token Delegate
extension SendTokenViewController: ChooseTokenDelegate {
    func didSelectToken(name: String) {
        popover.dismiss()
        guard let token = tokensService.availableTokensList()?.filter({$0.symbol.uppercased() == name.uppercased()}).first else { return }
        tokensService.updateSelectedToken(to: token.address)
        updateTopLayout()
    }
}

// MARK: TextField Delegate
extension SendTokenViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.returnKeyType = nextButton.isEnabled ? UIReturnKeyType.done : .next
        //let index = textFields.index(of: textField) ?? 0
        //separators[index].backgroundColor = UIColor.black
        textField.textColor = UIColor.black
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
        //let index = textFields.index(of: textField) ?? 0
        //separators[index].backgroundColor = WalletColors.greySeparator.color()
        textField.textColor = WalletColors.defaultText.color()
        
        
        if textField == amountTextfield {
            guard let _ = Float((amountTextfield.text ?? "")) else {
                //let amountIndex = textFields.index(of: amountTextfield) ?? 0
                //separators[amountIndex].backgroundColor = WalletColors.errorRed.color()
                amountTextfield.textColor = WalletColors.errorRed.color()
                return true
            }
        }
        return true
    }
}

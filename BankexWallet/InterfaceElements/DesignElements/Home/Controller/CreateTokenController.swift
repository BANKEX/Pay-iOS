//
//  CreateTokenController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 3/15/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import QRCodeReader

class CreateTokenController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var tokenAddedIcon: UIImageView!
    @IBOutlet weak var tokenAddedLabel: UILabel!
    @IBOutlet weak var pasteButton:UIButton!
    
    var needAddTokenAnimation = false
    
    var chosenToken: ERC20TokenModel?
    
    let tokensService: CustomERC20TokensService = CustomERC20TokensServiceImplementation()
    var tokensList: [ERC20TokenModel]?
    var tokensAvailability: [Bool]?
    var walletData = WalletData()
    
    let interactor = Interactor()
    
    lazy var readerVC:QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes:[.qr],captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPasteButton()
        tableView.tableFooterView = UIView()
        
        self.hideKeyboardWhenTappedAround()
        self.setupViewResizerOnKeyboardShown()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        tableView.alpha = 0
        tableView.isUserInteractionEnabled = false
        
        tokenAddedIcon.alpha = 0
        tokenAddedLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let searchText = searchBar.text else {
            return
        }
        DispatchQueue.main.async {
            if self.needAddTokenAnimation {
                self.needAddTokenAnimation = false
                self.tokenAddedIcon.alpha = 0.0
                self.tokenAddedLabel.alpha = 0.0
                UIView.animate(withDuration: 2.0, animations: {
                    self.tokenAddedIcon.alpha = 1.0
                    self.tokenAddedLabel.alpha = 1.0
                })
                UIView.animate(withDuration: 2.0, animations: {
                    self.tokenAddedIcon.alpha = 0.0
                    self.tokenAddedLabel.alpha = 0.0
                })
            }
            
            self.searchBar(self.searchBar, textDidChange: searchText)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    func setNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        self.title = NSLocalizedString("Add new token", comment: "")
    }
    
    @IBAction func scanTapped(_ sender:UIButton) {
        readerVC.delegate = self
        self.readerVC.modalPresentationStyle = .formSheet
        self.present(readerVC, animated: true)
    }
    
    @IBAction func textFromBuffer(_ sender:Any) {
        if let string = UIPasteboard.general.string  {
            searchBar.text = string
            DispatchQueue.main.async {
                self.searchBar(self.searchBar, textDidChange: string)
            }
        }
    }
    
    @IBAction func unwindFromAddVC(_ sender: UIStoryboardSegue) {
        if sender.source is TokenInfoController {
            self.needAddTokenAnimation = true
        }
    }
    
    fileprivate func setupPasteButton() {
        pasteButton.layer.borderColor = WalletColors.blueText.color().cgColor
        pasteButton.layer.borderWidth = 2.0
        pasteButton.layer.cornerRadius = 15.0
        pasteButton.setTitle(NSLocalizedString("Paste", comment: ""), for: .normal)
        pasteButton.setTitleColor(WalletColors.blueText.color(), for: .normal)
    }
}

extension CreateTokenController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}



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
    
    var chosenToken: ERC20TokenModel?
    var chosenTokenAmount: String?
    
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
        
        tableView.tableFooterView = UIView()
        
        self.hideKeyboardWhenTappedAround()
        self.setupViewResizerOnKeyboardShown()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        
        tableView.alpha = 0
        tableView.isUserInteractionEnabled = false

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let searchText = searchBar.text else {
            return
        }
        DispatchQueue.main.async {
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
        self.title = "Add New Token"
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
    
}

extension CreateTokenController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}



//
//  AttentionViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 20/08/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift



class AttentionViewController: BaseViewController {
    
    
    enum State {
        case PrivateKey,CustomNetwork
    }
    
    
    @IBOutlet weak var descriptionLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    var isFromDeveloper:Bool = false
    var publicAddress: String?
    var directionSegue:String = ""
    var state:State = .PrivateKey {
        didSet {
            if state == .PrivateKey {
                descriptionLabel.text = "Anyone who knows your private key has access to your wallet"
                titleLabel.text = "Private Key"
                directionSegue = "showPrivateKey"
            }else {
                descriptionLabel.text = "This option is intended for development use only"
                titleLabel.text = "Custom Networks"
                directionSegue = "showCustomNetworks"
            }
        }
    }
    let keysService = SingleKeyServiceImplementation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Private Key", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        state = isFromDeveloper ? .CustomNetwork : .PrivateKey
        navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.statusBarView?.backgroundColor = WalletColors.errorColor
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.statusBarView?.backgroundColor = .white
        UIApplication.shared.statusBarStyle = .default
    }
    
    @IBAction func proceed() {
        self.performSegue(withIdentifier: directionSegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddressQRCodeController {
            vc.navTitle = NSLocalizedString("Private Key", comment: "")
            let item = UIBarButtonItem()
            item.title = "Back"
            navigationItem.backBarButtonItem = item
            guard let selectedAddress = publicAddress, let ethAddress = EthereumAddress(selectedAddress) else { return }
            vc.addressToGenerateQR = try? keysService.keystoreManager(forAddress: selectedAddress).UNSAFE_getPrivateKeyData(password: "BANKEXFOUNDATION", account: ethAddress).toHexString()
//            let _ = try! keysService.keystoreManager(forAddress: selectedAddress).UNSAFE_getPrivateKeyData(password: "BANKEXFOUNDATION", account: ethAddress)
        }else if let netwokrsVC = segue.destination as? NetworksViewController {
            netwokrsVC.isFromDeveloper = true
        }
    }
    

    
    @IBAction func back() {
        navigationController?.popViewController(animated: true)
    }
}

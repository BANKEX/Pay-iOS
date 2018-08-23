//
//  AttentionViewController.swift
//  BankexWallet
//
//  Created by Георгий Фесенко on 20/08/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class AttentionViewController: UIViewController {
    
    var publicAddress: String?
    let keysService = SingleKeyServiceImplementation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Private Key"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddressQRCodeController {
            vc.navTitle = "Private Key"
            let item = UIBarButtonItem()
            item.title = "Back"
            navigationItem.backBarButtonItem = item
            guard let selectedAddress = publicAddress, let ethAddress = EthereumAddress(selectedAddress) else { return }
            vc.addressToGenerateQR = try? keysService.keystoreManager(forAddress: selectedAddress).UNSAFE_getPrivateKeyData(password: "BANKEXFOUNDATION", account: ethAddress).toHexString()
            let prk = try! keysService.keystoreManager(forAddress: selectedAddress).UNSAFE_getPrivateKeyData(password: "BANKEXFOUNDATION", account: ethAddress)
            print(prk.toHexString())
            print(String.init(data: prk, encoding: .ascii))
        }
    }
}

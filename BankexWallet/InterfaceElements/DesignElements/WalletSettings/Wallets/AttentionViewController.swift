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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddressQRCodeController {
            guard let selectedAddress = publicAddress, let ethAddress = EthereumAddress(selectedAddress) else { return }
            vc.addressToGenerateQR = try? keysService.keystoreManager(forAddress: selectedAddress).UNSAFE_getPrivateKeyData(password: "BANKEXFOUNDATION", account: ethAddress).toHexString()
        }
    }
}

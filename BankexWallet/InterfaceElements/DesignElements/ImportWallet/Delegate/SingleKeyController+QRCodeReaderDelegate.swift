//
//  QRCodeReaderViewControllerDelegate.swift
//  BankexWallet
//
//  Created by Vladislav on 19.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import QRCodeReader
import web3swift


extension SingleKeyWalletController:QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        privateKeyTextView.applyNotHolder()
        let value = result.value
        
        if let parsed = Web3.EIP67CodeParser.parse(value) {
            privateKeyTextView.text = parsed.address.address
        }else {
            privateKeyTextView.text = value
        }
        privateKeyTextView.becomeFirstResponder()
        state = .available
        dismiss(animated: true)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true)
    }
    
}


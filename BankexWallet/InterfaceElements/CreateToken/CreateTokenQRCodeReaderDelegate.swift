//
//  CreateTokenQRCode.swift
//  BankexWallet
//
//  Created by Антон Григорьев on 30.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import QRCodeReader

extension CreateTokenController:QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        let searchText = result.value.lowercased()
        self.searchBar.text = searchText
        dismiss(animated: true)
        DispatchQueue.main.async {
            self.searchBar(self.searchBar, textDidChange: searchText)
        }
        
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true)
    }
    
}

//
//  ImportPassphraseTests.swift
//  BankexWalletTests
//
//  Created by Vladislav on 06.09.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import KIF
@testable import BankexWallet

class ImportPassphraseTests:BaseTests {
    func testImportWalletUsingPassphrase() {
        if !firstEntry() {
            transitionFromMainScreenToWalletCreationScreen()
            importWalletPassphrase()
        }else {
            getRoundOnboarding()
            importWalletPassphrase()
            getRoundPasscodeScreen()
        }
        expectToSeeAlert("HomeLbl")
    }
    
    
    
}

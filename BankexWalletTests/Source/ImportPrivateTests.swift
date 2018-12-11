//
//  ImportTests.swift
//  BankexWalletTests
//
//  Created by Vladislav on 06.09.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import KIF


class ImportTests: BaseTests {
    
    
    func testImportWalletUsingPrivateKey() {
        if !firstEntry() {
            transitionFromMainScreenToWalletCreationScreen()
            importWallet()
        }else {
            getRoundOnboarding()
            importWallet()
            getRoundPasscodeScreen()
        }
        expectToSeeAlert("HomeLbl")
    }
    
    func importWallet() {
        tapButton("ImportWallet_Btn")
        let importSegmentControl = tester().waitForView(withAccessibilityLabel: "Import_SegmentControl") as! UISegmentedControl
        XCTAssertEqual(importSegmentControl.selectedSegmentIndex, 0)
        tapButton("privateTextView")
        prepareKeyboard()
        enterText(privateKeyString)
        tapButton("ContainerView")
        waitForHideKeyboard()
        tapButton("nameWalletTextField")
        prepareKeyboard()
        enterText(nameWallet)
        tapButton("ContainerView")
        waitForHideKeyboard()
        let importBtn = tester().waitForView(withAccessibilityLabel: "ImportBtn_ImportingScren") as! UIButton
        XCTAssertTrue(importBtn.isEnabled)
        tapButton("ImportBtn_ImportingScren")
    }
    
    
    
    
    

    
}


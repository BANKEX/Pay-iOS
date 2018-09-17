//
//  CreateWalletTests.swift
//  BankexWalletTests
//
//  Created by Vladislav on 08.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import KIF
@testable import BankexWallet

class CreateWalletTests: BaseTests {
    
    
    
    func testCreateWalletTests() {
        if !firstEntry() {
            transitionFromMainScreenToWalletCreationScreen()
            tapButton("createWallet")
            generateMnemonics()
            matchMnemonics()
            checkWalletCreated()
            changeWalletName()
            return
        }
        getRoundOnboarding()
        tapButton("createWallet")
        generateMnemonics()
        matchMnemonics()
        getRoundPasscodeScreen()
        checkWalletCreated()
        changeWalletName()
    }
    
    
    
    
    func changeWalletName() {
        tester().acknowledgeSystemAlert()
        let nameWalletLabel = tester().waitForView(withAccessibilityLabel: "walletNameLb") as! UILabel
        let previousNameWallet = nameWalletLabel.text!
        tapButton("EditBtn")
        tapButton("walletNameTf")
        prepareKeyboard()
        tester().clearTextFromFirstResponder()
        let walletName = "Wallet" + UUID().uuidString.prefix(4)
        enterText(walletName)
        tapButton("SaveBt")
        XCTAssertNotEqual(walletName, previousNameWallet)
        XCTAssertEqual(nameWalletLabel.text!, walletName)
        tapButton("next3")
    }
    
    func checkWalletCreated() {
        expectToSeeAlert("Wallet Created!")
    }
    
    
    func matchMnemonics() {
        let nextBtn = tester().waitForView(withAccessibilityLabel: "nextMnemonic") as! UIButton
        let beforeCollection = tester().waitForView(withAccessibilityLabel: "beforeLbl") as! UICollectionView
        let afterCollection = tester().waitForView(withAccessibilityLabel: "afterLbl") as! UICollectionView
        var row = 0
        var afterIndexPath = IndexPath(row: row, section: 0)
        while !nextBtn.isEnabled {
            let beforeIndexPath = IndexPath(item: 0, section: 0)
            tester().tapItem(at: beforeIndexPath, in: beforeCollection)
            if cellIsRed(afterCollection,afterIndexPath) {
                tester().tapItem(at: afterIndexPath, in: afterCollection)
            }else {
                row += 1
                afterIndexPath = IndexPath(item: row, section: 0)
            }
        }
        tapButton("nextMnemonic")
    }
    
    private func cellIsRed(_ collectionView:UICollectionView, _ index:IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: index) as! CollectionViewCell
        return cell.wordLabel.textColor == UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
    }
    
    func generateMnemonics() {
        tapButton("copy")
        let nextBtn = tester().waitForTappableView(withAccessibilityLabel: "nextCreate") as! UIButton
        XCTAssertTrue(nextBtn.isEnabled)
        tapButton("nextCreate")
    }
}

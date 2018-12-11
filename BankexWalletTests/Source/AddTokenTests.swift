//
//  AddTokenTests.swift
//  BankexWalletTests
//
//  Created by Vladislav on 06.09.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import KIF
@testable import BankexWallet


class AddTokenTests:BaseTests {
    
    
    func testSearchAndAddToken() {
        if !firstEntry() {
            enterInitialPin()
            expectToSeeAlert("HomeLbl")
            searchToken()
            addToken()
            checkAddedToken()
            returnBackMainScreen()
            expectToSeeAlert("WalletLbl")
        }
    }
    
    func searchToken() {
        tapButton("TokenTab")
        expectToSeeAlert("WalletLbl")
        tapButton("AddNewTokenBtn")
        tapButton("Search")
        prepareKeyboard()
        enterText("BKX")
    }
    
    func addToken() {
        let indexPath = IndexPath(row: 0, section: 0)
        tester().tapRow(at: indexPath, inTableViewWithAccessibilityIdentifier: "tokenTable")
        tapButton("addToken")
        tester().waitForAnimationsToFinish()
    }
    
    func checkAddedToken() {
        let tokensTable = receiveTableView("tokenLbl")
        let indexPath = IndexPath(row: 0, section: 0)
        let tokenCell = tokensTable.cellForRow(at: indexPath) as! CreateTokenCell
        XCTAssertEqual(tokenCell.tokenAddedImageView.alpha, CGFloat(1.0))
    }
    
    
    
    
    
//    func testDeleteToken() {
//        enterInitialPin()
//        expectToSeeAlert("HomeLbl")
//        tapButton("TokenTab")
//        expectToSeeAlert("WalletLbl")
//        tapButton("edit")
//        let editBtn =  tester().waitForTappableView(withAccessibilityLabel: "edit") as! UIButton
//        XCTAssertEqual(editBtn.currentTitle!, "Cancel")
//        //Continue
//    }
    
    
}
//WalletTabTokenCell
//tokenTable

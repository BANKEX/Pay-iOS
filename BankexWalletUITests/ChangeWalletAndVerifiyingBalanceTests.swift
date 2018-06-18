//
//  ChangeWalletAndVerifiyingBalanceTests.swift
//  BankexWalletUITests
//
//  Created by Георгий Фесенко on 30.05.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import XCTest

class ChangeWalletAndVerifiyingBalanceTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
    }
    
    override func tearDown() {
        Springboard.deleteMyApp()
        super.tearDown()
    }
    
    func testChangeWalletAndVerifyBalance() {
        
        let app = XCUIApplication()
        app.launch()
        
        //Importing first wallet
        let importWalletButton = app.buttons["ImportWalletBtn"]
        importWalletButton.tap()
        app.buttons["PassphraseBtn"].tap()
        
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        let passphraseTextField = elementsQuery/*@START_MENU_TOKEN@*/.textFields["EnterPassphraseTextfield"]/*[[".textFields[\"Enter your passphrase\"]",".textFields[\"EnterPassphraseTextfield\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        passphraseTextField.tap()
        passphraseTextField.typeText("river device easy safe open swift man century smooth seek draft clutch")
        
        let nextButton = app/*@START_MENU_TOKEN@*/.buttons["Next:"]/*[[".keyboards",".buttons[\"Next\"]",".buttons[\"Next:\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        nextButton.tap()
        
        let walletNamePassphraseTextfield = elementsQuery/*@START_MENU_TOKEN@*/.textFields["WalletNameTextFieldPassphrase"]/*[[".textFields[\"Name your wallet\"]",".textFields[\"WalletNameTextFieldPassphrase\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        walletNamePassphraseTextfield.tap()
        walletNamePassphraseTextfield.typeText("FirstWallet")
        nextButton.tap()
        
        let walletPasswordPassphraseTextfield = elementsQuery/*@START_MENU_TOKEN@*/.secureTextFields["WalletPasswordTextFieldPassphrase"]/*[[".secureTextFields[\"Password\"]",".secureTextFields[\"WalletPasswordTextFieldPassphrase\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        walletPasswordPassphraseTextfield.tap()
        walletPasswordPassphraseTextfield.typeText("123456")
        nextButton.tap()
        
        let walletPasswordRepeatPassphraseTextfield = elementsQuery/*@START_MENU_TOKEN@*/.secureTextFields["WalletPasswordRepeatPassphrase"]/*[[".secureTextFields[\"Repeat Password\"]",".secureTextFields[\"WalletPasswordRepeatPassphrase\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        walletPasswordRepeatPassphraseTextfield.tap()
        walletPasswordRepeatPassphraseTextfield.typeText("123456")
        nextButton.tap()
        let label = app.staticTexts["AmountLabel"]
        let exists = NSPredicate(format: "exists == 1 && label != \"0\"")
        
        expectation(for: exists, evaluatedWith: label, handler: nil)
        waitForExpectations(timeout: 40, handler: nil)
        let firstWalletAmount = label.label
        
        //Importing second wallet
        app.tabBars.buttons["Settings"].tap()
        app.tables.cells["WalletsListCell"].children(matching: .other).element(boundBy: 0).tap()
        app/*@START_MENU_TOKEN@*/.buttons["AddWalletBtn"]/*[[".buttons[\"Add\"]",".buttons[\"AddWalletBtn\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        importWalletButton.tap()
        app.buttons["PassphraseBtn"].tap()
        passphraseTextField.tap()
        passphraseTextField.typeText("spirit gravity surge chef silly spawn city boat split poverty twist peasant")
        walletNamePassphraseTextfield.tap()
        walletNamePassphraseTextfield.typeText("SecondWallet")
        nextButton.tap()
        walletPasswordPassphraseTextfield.tap()
        walletPasswordPassphraseTextfield.typeText("123456")
        walletPasswordRepeatPassphraseTextfield.tap()
        walletPasswordRepeatPassphraseTextfield.typeText("123456")
        nextButton.tap()
        
        
        let tabBarsQuery = app.tabBars
        let settingsButton = tabBarsQuery.buttons["Settings"]
        settingsButton.tap()
        
        //Changing wallet
        let tablesQuery = app.tables
        let element = tablesQuery.cells["WalletsListCell"].children(matching: .other).element(boundBy: 0)
        element.tap()
        tablesQuery.cells.containing(.staticText, identifier: "FirstWallet").children(matching: .other).element(boundBy: 0).tap()
        app.buttons["BackButton"].tap()
        app.buttons["Home"].tap()
        
        let newWalletAmount = app.staticTexts["AmountLabel"].label
        XCTAssertEqual(newWalletAmount, firstWalletAmount)
        
    }
    
}

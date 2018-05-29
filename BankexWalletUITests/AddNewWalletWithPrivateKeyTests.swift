//
//  AddNewWalletWithPrivateKeyTests.swift
//  BankexWalletUITests
//
//  Created by Георгий Фесенко on 29.05.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import XCTest


class AddNewWalletWithPrivateKeyTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddingNewWalletWithPrivateKey() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        app.tables.cells["WalletsListCell"].children(matching: .other).element(boundBy: 0).tap()
        app/*@START_MENU_TOKEN@*/.buttons["AddWalletBtn"]/*[[".buttons[\"Add\"]",".buttons[\"AddWalletBtn\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["CreateWalletBtn"].tap()
        
        let scrollViewsQuery = app.scrollViews
        let textField = scrollViewsQuery.otherElements.textFields["WalletNameTextFieldPrivate"]
        textField.tap()
        textField.typeText("myWallet")
        
        let walletpasswordtextfieldprivateSecureTextField = scrollViewsQuery.otherElements.secureTextFields["WalletPasswordTextFieldPrivate"]
        walletpasswordtextfieldprivateSecureTextField.tap()
        walletpasswordtextfieldprivateSecureTextField.typeText("password")
        
        let walletpasswordrepeatprivateSecureTextField = scrollViewsQuery.otherElements.secureTextFields["WalletPasswordRepeatPrivate"]
        walletpasswordrepeatprivateSecureTextField.tap()
        walletpasswordrepeatprivateSecureTextField.typeText("password")
        app.scrollViews.children(matching: .button).element(boundBy: 0).tap()
        
        let button = scrollViewsQuery.buttons["CreateWalletButtonPrivate"]
        
        button.tap()
        
        let txt = app.staticTexts["WalletNameLabel"].label
        
        XCTAssertEqual(txt, "myWallet")
        
    }
    
    func testAddingNewWalletWithPassphrase() {
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        app.tables.cells["WalletsListCell"].children(matching: .other).element(boundBy: 0).tap()
        app/*@START_MENU_TOKEN@*/.buttons["AddWalletBtn"]/*[[".buttons[\"Add\"]",".buttons[\"AddWalletBtn\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["CreateWalletBtn"].tap()
        
        app.buttons["PassphraseBtn"].tap()
        let scrollViewsQuery = app.scrollViews
        let textField = scrollViewsQuery.otherElements.textFields["WalletNameTextFieldPassphrase"]
        textField.tap()
        textField.typeText("myWallet")
        
        let walletpasswordtextfieldprivateSecureTextField = scrollViewsQuery.otherElements.secureTextFields["WalletPasswordTextFieldPassphrase"]
        walletpasswordtextfieldprivateSecureTextField.tap()
        walletpasswordtextfieldprivateSecureTextField.typeText("password")
        
        let walletpasswordrepeatprivateSecureTextField = scrollViewsQuery.otherElements.secureTextFields["WalletPasswordRepeatPassphrase"]
        walletpasswordrepeatprivateSecureTextField.tap()
        walletpasswordrepeatprivateSecureTextField.typeText("password")
        app.scrollViews.children(matching: .button).element(boundBy: 0).tap()
        
        let button = scrollViewsQuery.buttons["CreateWalletButtonPassphrase"]
        
        button.tap()
        
        app.buttons["DoneButton"].tap()
        
        let txt = app.staticTexts["WalletNameLabel"].label
        
        XCTAssertEqual(txt, "myWallet")
    }
    
}

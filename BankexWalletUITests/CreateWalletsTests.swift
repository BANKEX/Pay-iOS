//
//  CreateWalletsTests.swift
//  BankexWalletUITests
//
//  Created by Vladislav on 27.08.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import XCTest

class CreateWalletsTests: XCTestCase {
        
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
        app.launch()
        
        app.buttons["CreateWalletBtn"].tap()
        
        let scrollViewsQuery = app.scrollViews
        let textField = scrollViewsQuery.otherElements.textFields["WalletNameTextFieldPrivate"]
        textField.tap()
        textField.typeText("myWallet")
        
        let walletPasswordTextfieldPrivate = scrollViewsQuery.otherElements.secureTextFields["WalletPasswordTextFieldPrivate"]
        walletPasswordTextfieldPrivate.tap()
        walletPasswordTextfieldPrivate.typeText("password")
        
        let walletPasswordRepeatPrivateTextfield = scrollViewsQuery.otherElements.secureTextFields["WalletPasswordRepeatPrivate"]
        walletPasswordRepeatPrivateTextfield.tap()
        walletPasswordRepeatPrivateTextfield.typeText("password")
        app.scrollViews.children(matching: .button).element(boundBy: 0).tap()
        
        let button = scrollViewsQuery.buttons["CreateWalletButtonPrivate"]
        
        button.tap()
        
        let label = app.staticTexts["WalletNameLabel"]
        let exists = NSPredicate(format: "exists == 1")
        
        expectation(for: exists, evaluatedWith: label, handler: nil)
        waitForExpectations(timeout: 40, handler: nil)
        let txt = label.label
        
        XCTAssertEqual(txt, "myWallet")
        
    }
    
    func testAddingNewWalletWithPassphrase() {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["CreateWalletBtn"].tap()
        
        app.buttons["PassphraseBtn"].tap()
        let scrollViewsQuery = app.scrollViews
        let textField = scrollViewsQuery.otherElements.textFields["WalletNameTextFieldPassphrase"]
        textField.tap()
        textField.typeText("myWallet")
        
        let walletPasswordPrivateTextfield = scrollViewsQuery.otherElements.secureTextFields["WalletPasswordTextFieldPassphrase"]
        walletPasswordPrivateTextfield.tap()
        walletPasswordPrivateTextfield.typeText("password")
        
        let walletPasswordRepeatPrivateTextfield = scrollViewsQuery.otherElements.secureTextFields["WalletPasswordRepeatPassphrase"]
        walletPasswordRepeatPrivateTextfield.tap()
        walletPasswordRepeatPrivateTextfield.typeText("password")
        app.scrollViews.children(matching: .button).element(boundBy: 0).tap()
        
        let button = scrollViewsQuery.buttons["CreateWalletButtonPassphrase"]
        
        button.tap()
        
        app.buttons["DoneButton"].tap()
        
        let label = app.staticTexts["WalletNameLabel"]
        let exists = NSPredicate(format: "exists == 1")
        
        expectation(for: exists, evaluatedWith: label, handler: nil)
        waitForExpectations(timeout: 40, handler: nil)
        let txt = label.label
        
        XCTAssertEqual(txt, "myWallet")
    }
    
}

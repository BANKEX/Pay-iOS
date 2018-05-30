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
        continueAfterFailure = false
    }
    
    override func tearDown() {
        Springboard.deleteMyApp()
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

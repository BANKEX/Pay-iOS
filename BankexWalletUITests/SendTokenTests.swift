//
//  SendTokenTests.swift
//  BankexWalletUITests
//
//  Created by Vladislav on 27.08.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import XCTest

class SendTokenTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
    }
    
    override func tearDown() {
        Springboard.deleteMyApp()
        super.tearDown()
    }
    
    func testSendingToken() {
        let app = XCUIApplication()
        app.launch()
        //Importing first wallet
        let importwalletbtnButton = app.buttons["ImportWalletBtn"]
        importwalletbtnButton.tap()
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
        //nextButton.tap()
        
        let walletPasswordPassphraseTextfield = elementsQuery/*@START_MENU_TOKEN@*/.secureTextFields["WalletPasswordTextFieldPassphrase"]/*[[".secureTextFields[\"Password\"]",".secureTextFields[\"WalletPasswordTextFieldPassphrase\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        walletPasswordPassphraseTextfield.tap()
        walletPasswordPassphraseTextfield.typeText("123456")
        //nextButton.tap()
        
        
        let walletPasswordRepeatPassphraseTextfield = elementsQuery/*@START_MENU_TOKEN@*/.secureTextFields["WalletPasswordRepeatPassphrase"]/*[[".secureTextFields[\"Repeat Password\"]",".secureTextFields[\"WalletPasswordRepeatPassphrase\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        walletPasswordRepeatPassphraseTextfield.tap()
        walletPasswordRepeatPassphraseTextfield.typeText("123456")
        app.buttons["CreateWalletButtonPassphrase"].tap()
        let label = app.staticTexts["AmountLabel"]
        let exists = NSPredicate(format: "exists == 1 && label != \"0\"")
        
        expectation(for: exists, evaluatedWith: label, handler: nil)
        waitForExpectations(timeout: 40, handler: nil)
        let firstWalletAmount = label.label
        
        //Importing second wallet
        app.tabBars.buttons["Settings"].tap()
        
        
        app.tables.cells["WalletsListCell"].children(matching: .other).element(boundBy: 0).tap()
        
        
        app/*@START_MENU_TOKEN@*/.buttons["AddWalletBtn"]/*[[".buttons[\"Add\"]",".buttons[\"AddWalletBtn\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        importwalletbtnButton.tap()
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
        
        expectation(for: exists, evaluatedWith: label, handler: nil)
        waitForExpectations(timeout: 40, handler: nil)
        let secondWalletAmount = label.label
        
        
        app.tables/*@START_MENU_TOKEN@*/.buttons["SendButton"]/*[[".cells",".buttons[\"Send\"]",".buttons[\"SendButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        let addressTextField = elementsQuery.textFields["AddressTextField"]
        addressTextField.tap()
        addressTextField.typeText("0x10AD0985d15c20a9702aFa571Bc08aeeeA663654")
        
        
        
        let amountTextfield = elementsQuery/*@START_MENU_TOKEN@*/.textFields["AmountTextField"]/*[[".textFields[\"Amount\"]",".textFields[\"AmountTextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        amountTextfield.tap()
        amountTextfield.typeText("0.01")
        nextButton.tap()
        let passTxtField = elementsQuery.secureTextFields["PasswordTextField"]
        passTxtField.tap()
        passTxtField.typeText("123456")
        
        nextButton.tap()
        let button = app.buttons["NextButtonConfirm"]
        let buttonExists = NSPredicate(format: "exists == 1")
        
        expectation(for: buttonExists, evaluatedWith: button, handler: nil)
        waitForExpectations(timeout: 40, handler: nil)
        app/*@START_MENU_TOKEN@*/.buttons["NextButtonConfirm"]/*[[".scrollViews",".buttons[\"Send 0.01 Eth\"]",".buttons[\"NextButtonConfirm\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        let doneBtn = app.buttons["DoneButton"]
        expectation(for: buttonExists, evaluatedWith: doneBtn, handler: nil)
        waitForExpectations(timeout: 40, handler: nil)
        doneBtn.tap()
        
        let waitForTransactionComplete = NSPredicate(format: "label != %@", secondWalletAmount)
        expectation(for: waitForTransactionComplete, evaluatedWith: label, handler: nil)
        waitForExpectations(timeout: 60, handler: nil)
        
        
        let amountAfterSending = Double(label.label)!
        let amountBeforeSending = Double(secondWalletAmount)!
        print(amountBeforeSending - amountAfterSending)
        XCTAssertTrue(amountBeforeSending - amountAfterSending >= 0.01)
        
    }
    
}

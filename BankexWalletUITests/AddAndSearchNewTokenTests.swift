//
//  AddAndSearchNewTokenTests.swift
//  BankexWalletUITests
//
//  Created by Георгий Фесенко on 30.05.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import XCTest

class AddAndSearchNewTokenTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
    }
    
    override func tearDown() {
        Springboard.deleteMyApp()
        super.tearDown()
    }
    
    func testAddAndSearchNewToken() {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["CreateWalletBtn"].tap()
        
        let scrollViewsQuery = app.scrollViews
        let textFieldName = scrollViewsQuery.otherElements.textFields["WalletNameTextFieldPrivate"]
        textFieldName.tap()
        textFieldName.typeText("myWallet")
        
        let walletPasswordTextfieldPrivate = scrollViewsQuery.otherElements.secureTextFields["WalletPasswordTextFieldPrivate"]
        walletPasswordTextfieldPrivate.tap()
        walletPasswordTextfieldPrivate.typeText("password")
        
        let walletPasswordRepeatPrivateTextField = scrollViewsQuery.otherElements.secureTextFields["WalletPasswordRepeatPrivate"]
        walletPasswordRepeatPrivateTextField.tap()
        walletPasswordRepeatPrivateTextField.typeText("password")
        app.scrollViews.children(matching: .button).element(boundBy: 0).tap()
        
        let button = scrollViewsQuery.buttons["CreateWalletButtonPrivate"]
        
        button.tap()
        
        let label = app.staticTexts["WalletNameLabel"]
        let exists = NSPredicate(format: "exists == 1")
        
        expectation(for: exists, evaluatedWith: label, handler: nil)
        waitForExpectations(timeout: 40, handler: nil)
        let txt = label.label
        
        XCTAssertEqual(txt, "myWallet")
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["AddTokenButton"]/*[[".cells",".buttons[\"Button\"]",".buttons[\"AddTokenButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        let textField = app/*@START_MENU_TOKEN@*/.textFields["SearchTokenTextField"]/*[[".textFields[\"Find token\"]",".textFields[\"SearchTokenTextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        textField.tap()
        textField.typeText("BKX")
        
        app/*@START_MENU_TOKEN@*/.buttons["Search"]/*[[".keyboards.buttons[\"Search\"]",".buttons[\"Search\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["AddTokenButtonOnFindTokenScreen"]/*[[".buttons[\"Add Contract\"]",".buttons[\"AddTokenButtonOnFindTokenScreen\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.tabBars.buttons["Tokens"].tap()
        let name = tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.image, identifier:"Bankex")/*[[".cells.containing(.staticText, identifier:\"BKX\")",".cells.containing(.image, identifier:\"Bankex\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.staticTexts["TokenName"].label
        
        XCTAssertEqual("BKX", name)
    }
    
    
    
    
}

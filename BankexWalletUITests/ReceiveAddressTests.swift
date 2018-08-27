//
//  ReceiveAddressTests.swift
//  BankexWalletUITests
//
//  Created by Vladislav on 27.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import XCTest

class ReceiveAddressTests: XCTestCase {
    
    var app:XCUIApplication!
        
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
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
    
    func testReceiveAddressThoughQRCode() {
        
        let button = app.buttons["1"]
        button.tap()
        button.tap()
        button.tap()
        button.tap()
        let receiveBtn = app.tables.buttons["Receive"]
        let existReceiveBtn = receiveBtn.exists
        let hittableReceiveBtn = receiveBtn.isHittable
        XCTAssertEqual(existReceiveBtn, true)
        XCTAssertEqual(hittableReceiveBtn, true)
        app.tables/*@START_MENU_TOKEN@*/.buttons["Receive"]/*[[".cells.buttons[\"Receive\"]",".buttons[\"Receive\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let copyBtn = app.buttons["Copy wallet address"]
        XCTAssertEqual(copyBtn.exists, true)
        XCTAssertEqual(copyBtn.isHittable, true)
        app.buttons["Copy wallet address"].tap()
        app.navigationBars["Receive"].buttons["  Home"].tap()
    }
    
}

//
//  CustomTokenUtilsServiceTests.swift
//  BankexWalletTests
//
//  Created by Korovkina, Ekaterina  on 3/14/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import XCTest
@testable import BankexWallet
import BigInt

class CustomTokenUtilsServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetName() {
        //given
        let service = CustomTokenUtilsServiceImplementation()
        let expectationrer = expectation(description: "Example")
        service.name(completion:{(_) in
            expectationrer.fulfill()
        })

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testGetsymbol() {
        //given
        let service = CustomTokenUtilsServiceImplementation()
        let expectationrer = expectation(description: "Example")
        service.symbol(completion:{(_) in
            expectationrer.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDecimals() {
        //given
        let service = CustomTokenUtilsServiceImplementation()
        let expectationrer = expectation(description: "Example")
        service.decimals(completion:{(_) in
            expectationrer.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testGetBalance() {
        //given
        let service = CustomTokenUtilsServiceImplementation()
        let expectationrer = expectation(description: "Example")
        service.getBalance(for: "0xD3671e3d9BC2F737097Fe1E3aF4572c4529a5Ff3", completion:{(_) in
            expectationrer.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)

    }
}

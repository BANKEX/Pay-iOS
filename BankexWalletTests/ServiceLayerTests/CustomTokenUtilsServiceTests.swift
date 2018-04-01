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
    
    func testGetName() {
        //given
        let service = CustomTokenUtilsServiceImplementation()
        let expectationrer = expectation(description: "Example")
        service.name(for: "", completion:{(_) in
            expectationrer.fulfill()
        })

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testGetsymbol() {
        //given
        let service = CustomTokenUtilsServiceImplementation()
        let expectationrer = expectation(description: "Example")
        service.symbol(for: "", completion:{(_) in
            expectationrer.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDecimals() {
        //given
        let service = CustomTokenUtilsServiceImplementation()
        let expectationrer = expectation(description: "Example")
        service.decimals(for: "", completion:{(_) in
            expectationrer.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testGetBalance() {
        //given
        let service = CustomTokenUtilsServiceImplementation()
        let expectationrer = expectation(description: "Example")
        service.getBalance(for: "0xD3671e3d9BC2F737097Fe1E3aF4572c4529a5Ff3", address: "", completion:{(_) in
            expectationrer.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)

    }
}

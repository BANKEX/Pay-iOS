//
//  RecipientsAddressesServiceTests.swift
//  BankexWalletTests
//
//  Created by Korovkina, Ekaterina on 3/11/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import XCTest
@testable import BankexWallet

class RecipientsAddressesServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStoreAndRetrieveData() {
        //given
        let service = RecipientsAddressesServiceImplementation()
        service.store(address: "Some Another String", with: "Second Name")
        service.store(address: "Some String", with: "First Name")
        service.store(address: "Some afgerg String", with: "Third Name")

        //when
        let allAddresses = service.getAllStoredAddresses()
        
        //then
        XCTAssertEqual(allAddresses?.count, 3)
        XCTAssertEqual(allAddresses?.first?.0, "First Name")
        XCTAssertEqual(allAddresses?.last?.0, "Third Name")

        service.clearAllSavedAddresses()
    }
    
    func testDeletAddress() {
        //given
        let service = RecipientsAddressesServiceImplementation()
        service.store(address: "Some Another String", with: "Second Name")
        service.store(address: "Some String", with: "First Name")
        service.store(address: "Some afgerg String", with: "Third Name")
        
        //when
        service.delete(with: "First Name")
        let allAddresses = service.getAllStoredAddresses()
        
        //then
        XCTAssertEqual(allAddresses?.count, 2)
        XCTAssertEqual(allAddresses?.first?.0, "Second Name")
        XCTAssertEqual(allAddresses?.last?.0, "Third Name")
        
        service.clearAllSavedAddresses()
    }
    
    func testUpdateAddress() {
        //given
        let service = RecipientsAddressesServiceImplementation()
        service.store(address: "Some String", with: "First Name")
        service.store(address: "Another String", with: "Second Name")
        
        //when
        service.update(address: "Yet Another String", with: "First Name")
        let allAddresses = service.getAllStoredAddresses()
        
        //then
        XCTAssertEqual(allAddresses?.first?.1, "Yet Another String")
        XCTAssertEqual(allAddresses?.last?.1, "Another String")
        
    }
    
}

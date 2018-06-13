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
        service.store(address: "Some Another String", with: "Second Name") {_ in }
        service.store(address: "Some String", with: "First Name") {_ in }
        service.store(address: "Some afgerg String", with: "Third Name") {_ in }

        //when
        let allAddresses = service.getAllStoredAddresses()
        
        //then
        XCTAssertEqual(allAddresses?.count, 3)
        XCTAssertEqual(allAddresses?.first?.name, "First Name")
        XCTAssertEqual(allAddresses?.last?.name, "Third Name")

        service.clearAllSavedAddresses()
    }
    
    func testDeletAddress() {
        //given
        let service = RecipientsAddressesServiceImplementation()
        service.clearAllSavedAddresses()
        service.store(address: "Some Another String", with: "Second Name") {_ in }
        service.store(address: "Some String", with: "First Name") {_ in }
        service.store(address: "Some afgerg String", with: "Third Name") {_ in }
        
        //when
        service.delete(with: "Some String") { }
        let allAddresses = service.getAllStoredAddresses()
        
        //then
        XCTAssertEqual(allAddresses?.count, 2)
        XCTAssertEqual(allAddresses?.first?.name, "Second Name")
        XCTAssertEqual(allAddresses?.last?.name, "Third Name")
        service.clearAllSavedAddresses()
        
        
    }
    
    func testUpdateAddress() {
        //given
        let service = RecipientsAddressesServiceImplementation()
        service.store(address: "Some String", with: "First Name") {_ in }
        service.store(address: "Another String", with: "Second Name") {_ in }
        
        //when
        service.updateAddress(newAddress: "Yet Another String", byName: "First Name")
        let allAddresses = service.getAllStoredAddresses()
        
        //then
        XCTAssertEqual(allAddresses?.first?.address, "Yet Another String")
        XCTAssertEqual(allAddresses?.last?.address, "Another String")
        
    }
    
}

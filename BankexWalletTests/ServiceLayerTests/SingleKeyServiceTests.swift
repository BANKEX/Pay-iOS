//
//  SingleKeyServiceTests.swift
//  BankexWalletTests
//
//  Created by Korovkina, Ekaterina on 3/11/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import XCTest
@testable import BankexWallet
import BigInt

class SingleKeyServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRemoveAddress() {
        //given
        let service = SingleKeyServiceImplementation(pathToStoreKeys: "/TestKeystores", defaultPassword: "")
        
        //when
        service.createNewSingleAddressWallet()
        service.createNewSingleAddressWallet()
        service.createNewSingleAddressWallet()
        service.createNewSingleAddressWallet()
        
        //then
        XCTAssertEqual(service.fullListOfPublicAddresses()?.count, 4)
        
        //when
        let firstAddress = service.fullListOfPublicAddresses()?.first
        service.delete(address: firstAddress ?? "")
        
        //then
        XCTAssertEqual(service.fullListOfPublicAddresses()?.count, 3)
    }

    func testClearAll() {
        //given
        let service = SingleKeyServiceImplementation(pathToStoreKeys: "/TestKeystores", defaultPassword: "")
        service.createNewSingleAddressWallet()
        service.createNewSingleAddressWallet()
        service.createNewSingleAddressWallet()
        service.createNewSingleAddressWallet()
        
        //when
        service.clearAllWallets()
        
        //then
        XCTAssertEqual(service.fullListOfPublicAddresses()?.count, 0)

    }
    
}

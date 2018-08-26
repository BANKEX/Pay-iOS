//
//  SingleKeyServiceTests.swift
//  BankexWalletTests
//
//  Created by Vladislav on 26.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import XCTest
@testable import BankexWallet
import BigInt

class SingleKeyServiceTests: XCTestCase {
    
    var service:SingleKeyServiceImplementation!
    
    override func setUp() {
        super.setUp()
        service = SingleKeyServiceImplementation()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateAddress() {
        //let service = SingleKeyServiceImplementation()
        
        service.createNewSingleAddressWallet(with: nil) { _ in }
        service.createNewSingleAddressWallet(with: "Wallet Name 2") { _ in }
        service.createNewSingleAddressWallet(with: "Wallet Name 3") { _ in }
        service.createNewSingleAddressWallet(with: "Wallet Name 4", password: "Password", completion: { _ in })
        let countWallets:Int = service.fullListOfPublicAddresses()!.count
        XCTAssertEqual(countWallets, 4)
        service.clearAllWallets()
    }
    
    func testCreateAddressPrivateKey() {
        //let service = SingleKeyServiceImplementation()
        
        let privateKeys:[String:String] = ["first":"3a1076bf45ab87712ad64ccb3b10217737f7faacbf2872e88fdd9a537d8fe266","second":"3a1076bf45ab87712ad64ccb3b10217737f7faacbf2872e88fdd9a537d8fe265","third":"3a1076bf45ab87712ad64ccb3b10217737f7faacbf2872e88fdd9a537d8fe263","fourth":"3a1076bf45ab87712ad64ccb3b10217737f7faacbf2872e88fdd9a537d8fe261"]
        
        service.createNewSingleAddressWallet(with: "Wallet Name", fromText: privateKeys["first"]!, password: "Password", completion: { _ in })
        service.createNewSingleAddressWallet(with: nil, fromText: privateKeys["second"]!, password: "Password ...", completion: { _ in })
        service.createNewSingleAddressWallet(with: "Wallet Name", fromText: privateKeys["third"]!, password: nil, completion: { _ in })
        service.createNewSingleAddressWallet(with: nil, fromText: privateKeys["fourth"]!, password: nil, completion: { _ in })
        
        let countAddresses:Int = service.fullListOfPublicAddresses()!.count
        XCTAssertEqual(countAddresses, 4)
        service.clearAllWallets()
    }
    
    // TODO:
    func testRemoveAddress() {
        //given
        //let service = SingleKeyServiceImplementation()
        
        //when
        service.createNewSingleAddressWallet(with: "") { _ in}
        
        //then
        XCTAssertEqual(service.fullListOfPublicAddresses()?.count, 1)
        
        //when
        let firstAddress = service.fullListOfPublicAddresses()?.first
        service.delete(address: firstAddress ?? "")
        
        //then
        XCTAssertEqual(service.fullListOfPublicAddresses()?.count, 0)
        
        service.clearAllWallets()
    }
    
}

//
//  NetworkServiceTests.swift
//  BankexWalletTests
//
//  Created by Vladislav on 24.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import XCTest
@testable import BankexWallet
import BigInt

class NetworksServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    
    
    func testAddingNewNetwork() {
        //given
        let networkService = NetworksServiceImplementation()
        try! networkService.addCustomNetwork(name: "Some Name",
                                             networkId: BigUInt(67883),
                                             networkUrlString: "https://anotherNetwork.io/",
                                             accessToken: "someAccessToken")
        try! networkService.addCustomNetwork(name: "Some Another Name ",
                                             networkId: BigUInt(343),
                                             networkUrlString: "https://anotherNetwork.io/",
                                             accessToken: nil)
        
        let networksList = networkService.currentNetworksList()
        
        //then
        XCTAssertEqual(networksList.count, 2)
        XCTAssertEqual(networksList.first!.networkId, BigUInt(67883))
        XCTAssertEqual(networksList.first!.networkName, "Some Name")
    }
    
    func testDeletingNewNetwork() {
        //given
        let networkService = NetworksServiceImplementation()
        try! networkService.addCustomNetwork(name: "Some Name",
                                             networkId: BigUInt(67883),
                                             networkUrlString: "https://anotherNetwork.io/",
                                             accessToken: "someAccessToken")
        try! networkService.addCustomNetwork(name: "Some Another Name ",
                                             networkId: BigUInt(343),
                                             networkUrlString: "https://anotherNetwork.io/",
                                             accessToken: nil)
        
        try! networkService.deleteNetwork(with: BigUInt(67883))
        
        //when
        let networksList = networkService.currentNetworksList()
        
        //then
        XCTAssertEqual(networksList.count, 1)
        XCTAssertEqual(networksList.first!.networkId, BigUInt(343))
        XCTAssertEqual(networksList.first!.networkName, "Some Another Name ")
    }
    
}

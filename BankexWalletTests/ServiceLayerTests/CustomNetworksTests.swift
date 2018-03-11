//
//  CustomNetworksTests.swift
//  BankexWalletTests
//
//  Created by Korovkina, Ekaterina on 3/11/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import XCTest
@testable import BankexWallet
import BigInt

class CustomNetworksTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCodingOfCustomNetwork() {
        //given
        let customNetwork = CustomNetwork(networkName: "Some Name", networkId: BigUInt(67883), networkUrlString: "https://anotherNetwork.io", accessToken: "someAccessToken")
        let jsonEncoder = JSONEncoder()
        let codedNetwork = try! jsonEncoder.encode(customNetwork)
        
        //when
        let jsonDecoder = JSONDecoder()
        let decodedNetwork = try! jsonDecoder.decode(CustomNetwork.self, from: codedNetwork)
        
        //then
        XCTAssertEqual(decodedNetwork.fullNetworkUrl, customNetwork.fullNetworkUrl)
        XCTAssertEqual(decodedNetwork.networkId, customNetwork.networkId)
        XCTAssertEqual(decodedNetwork.networkName, customNetwork.networkName)
    }
    
    func testCodingOfCustomNetworkWithNils() {
        //given
        let customNetwork = CustomNetwork(networkName: nil, networkId: BigUInt(45367), networkUrlString: "https://anotherNetwork.io", accessToken: nil)
        let jsonEncoder = JSONEncoder()
        let codedNetwork = try! jsonEncoder.encode(customNetwork)
        
        //when
        let jsonDecoder = JSONDecoder()
        let decodedNetwork = try! jsonDecoder.decode(CustomNetwork.self, from: codedNetwork)
        
        //then
        XCTAssertEqual(decodedNetwork.fullNetworkUrl, customNetwork.fullNetworkUrl)
        XCTAssertEqual(decodedNetwork.networkId, customNetwork.networkId)
        XCTAssertEqual(decodedNetwork.networkName, customNetwork.networkName)
    }
}

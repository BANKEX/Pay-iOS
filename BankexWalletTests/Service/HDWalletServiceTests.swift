//
//  HDWalletServiceTests.swift
//  BankexWalletTests
//
//  Created by Vladislav on 24.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import XCTest
@testable import BankexWallet
import SugarRecord

class HDWalletServiceTests: XCTestCase {
    
    var service:HDWalletServiceImplementation!
    
    override func setUp() {
        super.setUp()
        service = HDWalletServiceImplementation()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        
        //after all
        super.tearDown()
    }
    
    
    func testCreateNewWallet() {
        //given
        let mnemonics = service.generateMnemonics()
        let expectationForCreate = expectation(description: "Example")
        var currentAddress:String?
        
        //when
        
        service.createNewHDWallet(with: "Wallet name", mnemonics: mnemonics, mnemonicsPassword: "MnemonicsPassword", walletPassword: "WalletPAssword") { (address, error) in
            currentAddress = address
            expectationForCreate.fulfill()
        }
        
        //then
        waitForExpectations(timeout: 0.3) { (error) in
            guard  error == nil else {
                XCTFail()
                return
            }
            let wallets = try! DBStorage.db.fetch(FetchRequest<KeyWallet>().filtered(with: "name", equalTo: "Wallet name"))
            XCTAssertEqual(wallets.count, 1)
            XCTAssertEqual(wallets.first?.isHD, true)
            self.service.clearAllWallets()
        }
    }
    
    func testUpdateWalletName() {
        let mnemonics = service.generateMnemonics()
        let expactationForUpdate = expectation(description: "Example")
        service.createNewHDWallet(with: "Just wallet name", mnemonics: mnemonics, mnemonicsPassword: "Password", walletPassword: "Password2") { (address, _) in
            let newName = "Wallet new name"
            self.service.updateWalletName(walletAddress:address!, newName: newName, completion: { _ in
                expactationForUpdate.fulfill()
            })
        }
        waitForExpectations(timeout: 0.3) { error in
            guard error == nil else {
                XCTFail()
                return
            }
            let wallets = try! DBStorage.db.fetch(FetchRequest<KeyWallet>().filtered(with: "name", equalTo: "Wallet new name"))
            XCTAssertEqual(wallets.count, 1)
            XCTAssertEqual(wallets.first!.name!, "Wallet new name")
            XCTAssertEqual(wallets.first!.isHD, true)
            self.service.clearAllWallets()
        }
        
    }
}

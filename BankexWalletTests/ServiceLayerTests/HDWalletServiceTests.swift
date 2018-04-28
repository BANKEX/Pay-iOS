//
//  HDWalletServiceTests.swift
//  BankexWalletTests
//
//  Created by Korovkina, Ekaterina  on 4/1/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import XCTest
@testable import BankexWallet
import SugarRecord

class HDWalletServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {

        //after all
        try! DBStorage.db.operation({ (context, save) in
            let localwallets = try! context.fetch(FetchRequest<KeyWallet>().filtered(with: "name", equalTo: "Wallet name"))
            
            try! context.remove(localwallets)
            save()
        })
        super.tearDown()
    }
    

    func testCreateNewWallet() {
        //given
        let service: HDWalletService = HDWalletServiceImplementation()
        let mnemonics = service.generateMnemonics()
        let expectationForCreate = expectation(description: "Example")

        //when
        
        service.createNewHDWallet(with: "Wallet name", mnemonics: mnemonics, mnemonicsPassword: "MnemonicsPassword", walletPassword: "WalletPAssword") { (address, error) in
            
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
            XCTAssertEqual(wallets.first?.isSelected, true)
            XCTAssertEqual(wallets.first?.isHD, true)
        }
    }
    
    func testCreateNewChildWallets() {
        //given
        let service: HDWalletService = HDWalletServiceImplementation()
        let mnemonics = service.generateMnemonics()
        let expectationForCreate = expectation(description: "Example")

        //when
        service.createNewHDWallet(with: "Wallet name", mnemonics: mnemonics, mnemonicsPassword: "MnemonicsPassword", walletPassword: "WalletPAssword") { (address, error) in
            let allKeys = service.fullHDKeysList()
            service.generateChildNode(with:"First Name", key: allKeys!.first!, password: "WalletPAssword", completion: { (_, _) in
//                service.generateChildNode(with: "Second Name", key: allKeys!.first!, password: "WalletPAssword", completion: { (_, _) in
                    expectationForCreate.fulfill()
//                })
            })
        }
        
        //then
        waitForExpectations(timeout: 10.3) { (error) in
            guard  error == nil else {
                XCTFail()
                return
            }
            let wallets = try! DBStorage.db.fetch(FetchRequest<KeyWallet>())
            XCTAssertEqual(wallets.count, 3)
        }
    }
    
}

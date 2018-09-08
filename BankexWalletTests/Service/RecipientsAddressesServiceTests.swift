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
    
    
    var service:RecipientsAddressesServiceImplementation!
    
    override func setUp() {
        super.setUp()
        service = RecipientsAddressesServiceImplementation()
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testStoreAndRetrieveData() {
        //given
        service.store(address: "Some Another String", with: "Second Name", lastName: "Second last name", isEditing: false) { _ in }
        service.store(address: "Some String", with: "First Name", lastName: "First last name", isEditing: false) { _ in }
        service.store(address: "Some afgerg String", with: "Third Name", lastName: "Third last name", isEditing: false) { _ in }

        //when
        let allAddresses = service.getAllStoredAddresses()
        
        //then
        XCTAssertEqual(allAddresses?.count, 3)
        XCTAssertEqual(allAddresses?.first?.firstName, "First Name")
        XCTAssertEqual(allAddresses?.last?.firstName, "Third Name")

        service.clearAllSavedAddresses()
    }
    
    func testDeletAddress() {
        //given
        service.clearAllSavedAddresses()
        service.store(address: "Some Another String", with: "Second Name", lastName: "Second last name", isEditing: false) { _ in }
        service.store(address: "Some String", with: "First Name", lastName: "First last name", isEditing: false) { _ in }
        service.store(address: "Some afgerg String", with: "Third Name", lastName: "Third last name", isEditing: false) { _ in }

        //when
        service.delete(with: "Some String") { }
        let allAddresses = service.getAllStoredAddresses()

        //then
        XCTAssertEqual(allAddresses?.count, 2)
        XCTAssertEqual(allAddresses?.first?.firstName, "Second Name")
        XCTAssertEqual(allAddresses?.last?.firstName, "Third Name")
        service.clearAllSavedAddresses()
    }

    func testUpdateAddress() {
        //given
        service.store(address: "Some String", with: "First Name", lastName: "First last name", isEditing: false) { _ in }
        service.store(address: "Another String", with: "Second Name", lastName: "Second last name", isEditing: false) { _ in }

        //when
        service.updateAddressBylastName(newAddress: "Another address", byName: "First last name")
        let allAddresses = service.getAllStoredAddresses()

        //then
        XCTAssertEqual(allAddresses?.first?.address, "Another address")
        XCTAssertEqual(allAddresses?.last?.address, "Another String")
        
        service.clearAllSavedAddresses()
    }
    
    func testUpdateNote() {
        service.store(address: "Some String", with: "First Name", lastName: "First last name", isEditing: false) { _ in }
        service.store(address: "Another String", with: "Second Name", lastName: "Second last name", isEditing: false) { _ in }
        service.updateNote(note: "Note", byAddress: "Another String")
        let currentNote = service.getAllStoredAddresses()?.last?.note
        XCTAssertNotNil(currentNote)
        XCTAssertEqual(currentNote!, "Note")
    }
    
    func testUpdateFirstName() {
        service.store(address: "Some String", with: "First Name", lastName: "First last name", isEditing: false) { _ in }
        service.store(address: "Another String", with: "Second Name", lastName: "Second last name", isEditing: false) { _ in }
        service.updateFirstName(newName: "New first name", byAddress:"Some String")
        let currentName = service.getAllStoredAddresses()?.first?.firstName
        XCTAssertNotNil(currentName)
        XCTAssertEqual(currentName!, "New first name")
    }
    
    func testUpdateLastName() {
        service.store(address: "Some String", with: "First Name", lastName: "First last name", isEditing: false) { _ in }
        service.store(address: "Another String", with: "Second Name", lastName: "Second last name", isEditing: false) { _ in }
        service.updateLastName(newName: "New last name", byAddress:"Another String")
        let currentName = service.getAllStoredAddresses()?.last?.lastname
        XCTAssertNotNil(currentName)
        XCTAssertEqual(currentName!, "New last name")
    }
    
}

//
//  RecipientsAddressesServiceTests.swift
//  BankexWalletTests
//
//  Created by Korovkina, Ekaterina on 3/11/2561 BE.
//  Copyright © 2561 BANKEX Foundation. All rights reserved.
//

import XCTest
@testable import BankexWallet

class RecipientsAddressesServiceTests: XCTestCase {
    
    
    var service:ContactService!
    
    override func setUp() {
        super.setUp()
        service = ContactService()
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
        let allAddresses = service.listContacts()
        
        //then
        XCTAssertEqual(allAddresses?.count, 3)
        XCTAssertEqual(allAddresses?.first?.firstName, "First Name")
        XCTAssertEqual(allAddresses?.last?.firstName, "Third Name")

        service.removeAll()
    }
    
    func testDeletAddress() {
        //given
        service.removeAll()
        service.store(address: "Some Another String", with: "Second Name", lastName: "Second last name", isEditing: false) { _ in }
        service.store(address: "Some String", with: "First Name", lastName: "First last name", isEditing: false) { _ in }
        service.store(address: "Some afgerg String", with: "Third Name", lastName: "Third last name", isEditing: false) { _ in }

        //when
        service.delete(with: "Some String") { }
        let allAddresses = service.listContacts()

        //then
        XCTAssertEqual(allAddresses?.count, 2)
        XCTAssertEqual(allAddresses?.first?.firstName, "Second Name")
        XCTAssertEqual(allAddresses?.last?.firstName, "Third Name")
        service.removeAll()
    }

    func testUpdateAddress() {
        //given
        service.store(address: "Some String", with: "First Name", lastName: "First last name", isEditing: false) { _ in }
        service.store(address: "Another String", with: "Second Name", lastName: "Second last name", isEditing: false) { _ in }

        //when
        service.updateAddressByName(newAddress: "Another address", byName: "First last name")
        let allAddresses = service.listContacts()

        //then
        XCTAssertEqual(allAddresses?.first?.address, "Another address")
        XCTAssertEqual(allAddresses?.last?.address, "Another String")
        
        service.removeAll()
    }
    
    func testUpdateNote() {
        service.store(address: "Some String", with: "First Name", lastName: "First last name", isEditing: false) { _ in }
        service.store(address: "Another String", with: "Second Name", lastName: "Second last name", isEditing: false) { _ in }
        service.updateNote(note: "Note", byAddress: "Another String")
        let currentNote = service.listContacts()?.last?.note
        XCTAssertNotNil(currentNote)
        XCTAssertEqual(currentNote!, "Note")
    }
    
    func testUpdateFirstName() {
        service.store(address: "Some String", with: "First Name", lastName: "First last name", isEditing: false) { _ in }
        service.store(address: "Another String", with: "Second Name", lastName: "Second last name", isEditing: false) { _ in }
        service.updateName(newName: "New first name", byAddress:"Some String")
        let currentName = service.listContacts()?.first?.firstName
        XCTAssertNotNil(currentName)
        XCTAssertEqual(currentName!, "New first name")
    }
    
    func testUpdateLastName() {
        service.store(address: "Some String", with: "First Name", lastName: "First last name", isEditing: false) { _ in }
        service.store(address: "Another String", with: "Second Name", lastName: "Second last name", isEditing: false) { _ in }
        service.updateLastName(newName: "New last name", byAddress:"Another String")
        let currentName = service.listContacts()?.last?.lastname
        XCTAssertNotNil(currentName)
        XCTAssertEqual(currentName!, "New last name")
    }
    
}

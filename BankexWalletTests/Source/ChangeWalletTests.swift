//
//  ChangeWalletTests.swift
//  BankexWalletTests
//
//  Created by Vladislav on 06.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import KIF
@testable import BankexWallet

class ChangeWalletTests: BaseTests {
    
    var selectedAddr:String!
    
    func testChangeWalletAndChackAddresses() {
        if !firstEntry() {
            enterInitialPin()
            expectToSeeAlert("HomeLbl")
            let addrLbl = tester().waitForView(withAccessibilityLabel: "AddrLbl") as! UILabel
            selectedAddr = addrLbl.text!
            tapButton("SettingsTab")
            let indexPath = IndexPath(row: 1, section: 0)
            tester().tapRow(at: indexPath, inTableViewWithAccessibilityIdentifier: "SettingTableView")
            let walletsTableVIew = tester().waitForView(withAccessibilityLabel: "walletTableView") as! UITableView
            XCTAssertEqual(walletsTableVIew.numberOfSections, 2)
            XCTAssertNotEqual(walletsTableVIew.numberOfRows(inSection: 1), 0)
            XCTAssertEqual(walletsTableVIew.numberOfRows(inSection: 0), 1)
            let rows = walletsTableVIew.numberOfRows(inSection: 1)
            if rows > 1 {
                if let indexPath = returnUnmatchedAddress(walletTableView: walletsTableVIew, rows: rows) {
                    tester().tapRow(at: indexPath, inTableViewWithAccessibilityIdentifier: "walletTableidentifier")
                    tapButton("MainTab")
                    XCTAssertNotEqual(selectedAddr,addrLbl.text!)
                }
            }
            expectToSeeAlert("HomeLbl")
        }
        
    }
    
    func returnUnmatchedAddress(walletTableView:UITableView,rows:Int) -> IndexPath? {
        for row in 0..<rows {
            let indexPath = IndexPath(row: row, section: 1)
            let walletCell = walletTableView.cellForRow(at: indexPath) as! WalletCell
            if walletCell.address != selectedAddr {
                return IndexPath(row: row, section: 1)
            }
        }
        return nil
    }
}

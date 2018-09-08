//
//  BaseTests.swift
//  BankexWalletTests
//
//  Created by Vladislav on 06.09.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import KIF
@testable import BankexWallet


class BaseTests:KIFTestCase {
    
    public let secondAddr = "0x2c3Bd8909e9Ce5FDB21fD1a86bc816B92C084347"

    
    var keysService = SingleKeyServiceImplementation()
    
    let privateKeyString = "6b039032b8928aec560949805d15c040599c4587cdcd17d8ae3ef5e9de35caf0"
    let nameWallet = "Wallet" + UUID().uuidString.prefix(5)
    
    
    func getRoundOnboarding() {
        //Only simulator
        tester().acknowledgeSystemAlert()
        //TODO Later can add swipe
        for _ in 0...2 {
            tapButton("nextBtn_Onboarding")
        }
    }
    
   
    
    
    func getRoundPasscodeScreen() {
        for _ in 0...1 {
            for _ in 0...3 {
                tapButton("firstNumBtn")
            }
        }
    }
    
    func importWalletPassphrase() {
        tapButton("ImportWallet_Btn")
        let importSegmentControl = tester().waitForView(withAccessibilityLabel: "Import_SegmentControl") as! UISegmentedControl
        let y = importSegmentControl.center.y
        let x = importSegmentControl.center.x + importSegmentControl.bounds.width/4
        tester().tapScreen(at: CGPoint(x: x, y: y))
        XCTAssertEqual(importSegmentControl.selectedSegmentIndex, 1)
        tapButton("PassphraseTextVIew")
        prepareKeyboard()
        let fakeMnemonics = UUID().uuidString
        enterText(fakeMnemonics)
        tapButton("ContainerViewPass")
        tapButton("passphraseNameTF")
        prepareKeyboard()
        enterText(nameWallet)
        tapButton("ContainerViewPass")
        let importBtn = tester().waitForTappableView(withAccessibilityLabel: "importPassphraseBtn") as! UIButton
        XCTAssertEqual(importBtn.isEnabled, true)
        tapButton("importPassphraseBtn")
    }
    
    func transitionFromMainScreenToWalletCreationScreen() {
        enterInitialPin()
        expectToSeeAlert("HomeLbl")
        tapButton("SettingsTab")
        let indexPath = IndexPath(row: 1, section: 0)
        tester().tapRow(at: indexPath, inTableViewWithAccessibilityIdentifier: "SettingTableView")
        tapButton("AddBtn")
    }
    
    func returnBackMainScreen() {
        let accuratePoint = CGPoint(x: 30.0, y: 30.0)
        tester().tapScreen(at: accuratePoint)
    }
    
    func enterInitialPin() {
        for _ in 0...3 {
            tapButton("EnterPinBtn")
        }
    }
    
    func firstEntry() -> Bool {
        return !UserDefaults.standard.bool(forKey: "passcodeExists") || keysService.selectedWallet() == nil
    }
    
    func receiveTableView(_ name:String) -> UITableView {
        return tester().waitForView(withAccessibilityLabel: name) as! UITableView
    }
    
    func tapButton(_ name:String) {
        tester().tapView(withAccessibilityLabel: name)
    }
    
    func expectToSeeAlert(_ name:String) {
        tester().waitForView(withAccessibilityLabel: name)
    }
    
    func enterText(_ name:String) {
        tester().enterText(intoCurrentFirstResponder: name)
    }
    
    func prepareKeyboard() {
        tester().waitForSoftwareKeyboard()
        tester().waitForKeyInputReady()
    }
    
    func waitForHideKeyboard() {
        tester().waitForAbsenceOfSoftwareKeyboard()
    }
    
}

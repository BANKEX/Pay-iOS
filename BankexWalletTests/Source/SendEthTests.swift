//
//  SendEthTests.swift
//  BankexWalletTests
//
//  Created by Vladislav on 07.09.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import KIF
@testable import BankexWallet


class SendEthTests: BaseTests {
    
    
    func testSendEth() {
        if !firstEntry() {
            enterInitialPin()
            expectToSeeAlert("HomeLbl")
            if checkBalance() {
                // Plus balance
                tapButton("send")
                let nameToken = checkNameToken() ?? ""
                XCTAssertEqual(nameToken, "ETH")
                enterData()
                let nextBtn = tester().waitForTappableView(withAccessibilityLabel: "next2") as! UIButton
                XCTAssertEqual(nextBtn.isEnabled, true)
                tapButton("next2")
                setDataForSliders()
                let nextBtn2 = tester().waitForTappableView(withAccessibilityLabel: "send2To") as! UIButton
                XCTAssertEqual(nextBtn2.isEnabled, true)
                tapButton("send2To")
                tapButton("send3")
                if UserDefaults.standard.bool(forKey:Keys.sendSwitch.rawValue) {
                    enterInitialPin()
                }
                tester().waitForAnimationsToFinish()
                let success = tester().waitForView(withAccessibilityLabel: "success") as! UILabel
                XCTAssertEqual(success.text!, "Success")
                tapButton("finish")
                expectToSeeAlert("HomeLbl")
                checkSentTransaction()
            }else {
                // Balance 0
            }
        }
    }
    
    
    
    func formatAddr(_ addr:String) -> String {
        return String(addr.dropFirst(4))
    }
    
    func formatAmountValue(_ str:String) -> String {
        var tempStr = str
        tempStr = String(str.dropFirst(2))
        return String(tempStr.dropLast(4))
    }
    
    
    //If balance more 0 then return YES
    func checkBalance() -> Bool {
        let amountLabel = tester().waitForView(withAccessibilityLabel: "amount") as! UILabel
        let amount = Double(amountLabel.text!) ?? 0.0
        return amount > 0.0
    }
    
    func checkNameToken() -> String? {
        let tokenBtn = tester().waitForTappableView(withAccessibilityLabel: "tokenArrowDown") as! UIButton
        let nameOfToken = tokenBtn.currentTitle
        return nameOfToken
    }
    
    func setDataForSliders() {
        let gasPriceTF = tester().waitForView(withAccessibilityLabel: "gasPrice") as! UITextField
        let gasLimitTF = tester().waitForView(withAccessibilityLabel: "gasLimit") as! UITextField
        let selectedGasPrice = gasPriceTF.text!
        let selectedGasLimit = gasLimitTF.text!
        setValueForSlider("gasPriceSlider", 3.5)
        setValueForSlider("gasLimitSlider", 10.0)
        XCTAssertNotEqual(gasPriceTF.text!, selectedGasPrice)
        XCTAssertNotEqual(gasLimitTF.text!, selectedGasLimit)
    }
    
    func checkSentTransaction() {
        let mainTable = receiveTableView("mainTable")
        let firstIndexPath = IndexPath(row: 3, section: 0)
        let historyCell = mainTable.cellForRow(at: firstIndexPath) as! TransactionHistoryCell
        let amount = historyCell.amountLabel.text ?? ""
        let formattedAmount = formatAmountValue(amount)
        XCTAssertEqual(formattedAmount, "0.0001")
        let toAddr = historyCell.addressLabel.text ?? ""
        let formattedAddr = formatAddr(toAddr)
        let prefix = formattedAddr.prefix(5)
        let suffix = formattedAddr.suffix(5)
        XCTAssertEqual(prefix, secondAddr.prefix(5))
        XCTAssertEqual(suffix, secondAddr.suffix(5))
    }
    
    func enterData() {
        tapButton("addrEnter")
        prepareKeyboard()
        enterText(secondAddr)
        resignKeyboard()
        waitForHideKeyboard()
        tapButton("amountTF")
        prepareKeyboard()
        enterText("0.0001")
        resignKeyboard()
        waitForHideKeyboard()
    }
    
    func resignKeyboard() {
        tapButton("resign")
    }
    
    func setValueForSlider(_ name:String, _ value:Float) {
        tester().setValue(value, forSliderWithAccessibilityLabel: name)
    }
}

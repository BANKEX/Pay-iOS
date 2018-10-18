//
//  AutoLockService.swift
//  BankexWallet
//
//  Created by Vladislav on 18/10/2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

final class AutoLockService {
    
    public static let shared = AutoLockService()
    
    var timer:Timer?
    
    var isRunning = false
    
    var selectedTime:TimeInterval {
        guard let timeString = getState() else { return 0 }
        return TimeInterval(timeString.components(separatedBy: " ").first!)!
    }
    
    func saveState(_ time:String) {
        UserDefaults.standard.set(time, forKey: "Time")
    }
    
    func getState() -> String? {
        return UserDefaults.standard.string(forKey: "Time")
    }
    
    func launchTimer() {
        isRunning = true
        timer = Timer(timeInterval: selectedTime, target: self, selector: #selector(done), userInfo: nil, repeats: false)
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    
    @objc func done() {
        isRunning = false
    }
}

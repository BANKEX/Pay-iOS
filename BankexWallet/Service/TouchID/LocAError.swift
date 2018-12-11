//
//  LocAError.swift
//  BankexWallet
//
//  Created by Vladislav on 25.07.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import UIKit
import LocalAuthentication

public enum LocAError {
    case userCancelled,failed,systemCancelled,biometryNotAvailable,biometryLockedOut,other
    
    static func initError(_ error:LAError) -> LocAError {
        switch Int32(error.errorCode) {
        case kLAErrorAuthenticationFailed:
            return failed
        case kLAErrorUserCancel:
            return userCancelled
        case kLAErrorSystemCancel:
            return systemCancelled
        case kLAErrorBiometryLockout:
            return biometryLockedOut
        case kLAErrorBiometryNotAvailable:
            return biometryNotAvailable
        default: return other
        }
    }
    
    
    func getErrorMessage() -> String {
        switch self {
        case .biometryNotAvailable: return  biometricsNotAvailableReason
        case .biometryLockedOut: return touchIdPasscodeAuthenticationStringReason
        case .userCancelled, .systemCancelled: return ""
        default: return defaultTouchIDAuthenticationStringReason
        }
    }
}

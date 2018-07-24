//
//  File.swift
//  BankexWallet
//
//  Created by Vladislav on 25.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import LocalAuthentication

typealias SuccessCallbank = (()->())
typealias FailureCallback = ((LocAError)->())


public class TouchManager:NSObject {
    
    
   
    
    public static let shared = TouchManager()
    
    /// Just check available touchID on device
    class func canAuth() -> Bool {
        var isAvailableAuthentication = false
        var error:NSError? = nil
        
        isAvailableAuthentication = LAContext().canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        return isAvailableAuthentication
    }
    
    
    /// Check for authentication
    class func authenticateBioMetrics(reason:String = "",cancelString:String? = nil,fallbackString:String? = nil,success:@escaping SuccessCallbank, failure:@escaping FailureCallback) {
        
        let stringReason:String = reason.isEmpty ? TouchManager.shared.defaultReason() : reason
        
        let context = LAContext()
        
        context.localizedFallbackTitle = fallbackString
        
        if #available(iOS 10.0, *) {
            context.localizedCancelTitle = cancelString
        }
        
        TouchManager.shared.evaluate(context: context, reason: stringReason, policy: LAPolicy.deviceOwnerAuthenticationWithBiometrics, sucess: success, failure: failure)
        
    }
    
    /// Get authentication reason
    private func defaultReason() -> String {
        return touchIDAuthenticationStringReason
    }
    
    ///Evaluate with policy
    private func evaluate(context:LAContext,reason:String,policy:LAPolicy,sucess successBlock:@escaping SuccessCallbank,failure failBlock:@escaping FailureCallback) {
        context.evaluatePolicy(policy, localizedReason: reason) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    successBlock()
                }else {
                    let typeError = LocAError.initError(error as! LAError)
                    failBlock(typeError)
                }
            }
        }
    }
}





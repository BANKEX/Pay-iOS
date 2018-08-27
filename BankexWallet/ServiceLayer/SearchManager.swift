//
//  SearchManager.swift
//  BankexWallet
//
//  Created by Vladislav on 31.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import CoreSpotlight
import MobileCoreServices


extension FavoriteModel {
    public static let domainIdentifier = "com.bankex.pay.contacts"
    
    public var userActivityUserInfo:[AnyHashable:Any] {
        return ["id".updateToNSSting():address.updateToNSSting()]
    }
    
    public var userActivity:NSUserActivity {
            let activity = NSUserActivity(activityType: FavoriteModel.domainIdentifier)
            activity.title = fullName
            activity.userInfo = userActivityUserInfo
            activity.keywords = [firstName,lastname,address]
            activity.contentAttributeSet = attributeSet
            return activity
    }
    
    public var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(
            itemContentType: kUTTypeContact as String)
        attributeSet.title = fullName
        attributeSet.contentDescription = note ?? "Note!!!"
        attributeSet.emailAddresses = [address]
        attributeSet.keywords = [firstName,lastname,address]
        return attributeSet
    }
}

//
//  SearchManager.swift
//  BankexWallet
//
//  Created by Vladislav on 31.08.2018.
//  Copyright © 2018 BANKEX Foundation. All rights reserved.
//

import Foundation
import CoreSpotlight
import MobileCoreServices


class SearchManager {
    
    var contact:FavoriteModel!
    
    init(contact:FavoriteModel) {
        self.contact = contact
    }
    
    func index() {
        CSSearchableIndex.default().indexSearchableItems([contact.searchableItem], completionHandler: { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Contact indexed successfully")
        })
    }
    
    func deindex() {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [(self.contact.userActivity.contentAttributeSet?.relatedUniqueIdentifier!)!], completionHandler: { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Contact deindexed successfully")
        })
    }
    
}



extension FavoriteModel {
    public static let domainIdentifier = "com.bankex.pay.contacts"
    
    public var userActivityUserInfo:[AnyHashable:Any] {
        return ["id".updateToNSSting():address.updateToNSSting()]
    }
    
    public var uniqueIdentifier:String {
        return address
    }
    
    public var searchableItem:CSSearchableItem {
        return CSSearchableItem(uniqueIdentifier: self.uniqueIdentifier, domainIdentifier: FavoriteModel.domainIdentifier, attributeSet: attributeSet)
    }
    
    public var userActivity:NSUserActivity {
        let activity = NSUserActivity(activityType: FavoriteModel.domainIdentifier)
        activity.title = name
        activity.userInfo = userActivityUserInfo
        activity.keywords = [name,address]
        activity.contentAttributeSet = attributeSet
        return activity
    }
    
    public var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(
            itemContentType: kUTTypeContact as String)
        attributeSet.title = name
        attributeSet.keywords = [name,address]
        attributeSet.relatedUniqueIdentifier = self.uniqueIdentifier
        return attributeSet
    }
}

//
//  AppConfig.swift
//  Covet
//
//  Created by Covet on 2/2/22.
//

import Foundation
import UIKit

class AppConfig {
    static let PRIVACY_POLICY_LINK: String = "https://covetapp.github.io/covet_legal/privacy-policy.html"
    static let TERMS_AND_CONDITIONS_LINK: String = "https://covetapp.github.io/covet_legal/terms-of-service.html"
    
    static let FOLLOWER_TIER_ALIAS: String = "Follower" // "Window Shopper"
    static let FOLLOWER_TIER_ALIAS_PLURAL: String = "Followers" // "Window Shoppers"
    
    static let FOLLOWS_ME_ALIAS: String = "Followed By" //"Window Shopped By"
    static let I_FOLLOW_ALIAS: String = "Following" // "Window Shops"
    
    static let FRIEND_TIER_ALIAS: String = "Friend" // "Big Spender"
    static let FRIEND_TIER_ALIAS_PLURAL: String = "Friends" // Big Spenders"
    
    static let FOLLOWER_TIER_ICON: String = "person" // "bag"
    static let FOLLOWER_TIER_ICON_FILLED: String = "person.fill" // "bag.fill"
    static let FRIEND_TIER_ICON: String = "person.2" // gift"
    static let FRIEND_TIER_ICON_FILLED: String = "person.2.fill" // gift.fill"
    
    static func getCovetImageWidth() -> CGFloat {
        if UIScreen.width <= 320 {
            return 200.0
        } else {
            return 250.0
        }
    }
}

//
//  CovetUser.swift.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Foundation
import Firebase
import SwiftyJSON
import PromiseKit

struct CovetUserRelationshipInfo : Decodable {
    
    // The other user, regardless of the "direction" of the relationship
    var user: CovetUser;
    
    // The relationship object itself
    var relationship: CovetUserRelationship;
    
}

struct CovetUser: Identifiable, Decodable {

        var id: Int;
        var authId: String;
        var username: String;
        var name: String?;
        var bio: String?;
        var birthday: Date?;
        var address: String?;
        
        var privateForFollowing: Bool;
        var privateForFriending: Bool;
    
        var follows: [CovetUserRelationshipInfo]?
        var followers: [CovetUserRelationshipInfo]?
        var friends: [CovetUserRelationshipInfo]?
        var pending: [CovetUserRelationshipInfo]?
    
        var current_user_is_following: Bool?
        var current_user_is_pending_following: Bool?
        var current_user_is_friending: Bool?
        var current_user_is_pending_friending: Bool?
        var current_user_is_pending_friended: Bool?
        var current_user_is_followed_by: Bool?
        var current_user_is_pending_followed_by: Bool?
        var current_user_blocks: Bool?
    
        var posts: [Post]?
    
        func currentUserFollows() -> Bool {
            return current_user_is_following!
        }
    
        func currentUserFollowedBy() -> Bool {
            return current_user_is_followed_by!
        }
    
        func currentUserFriend() -> Bool {
            return current_user_is_friending!
        }
    
        func currentUserPendingOutgoing() -> Bool {
            return current_user_is_pending_following! || current_user_is_pending_friending!
        }
    
        func currentUserPendingIncoming() -> Bool {
            return current_user_is_pending_followed_by! || current_user_is_pending_friended!
        }
    
        func currentUserBlocks() -> Bool {
            return current_user_blocks!
        }
    
    func allRelationshipInformationPresent() -> Bool {
        guard
            let _ = self.current_user_is_following,
            let __ = self.current_user_is_pending_following,
            let ___ = self.current_user_is_friending,
            let ____ = self.current_user_is_pending_friending,
            let _____ = self.current_user_is_pending_friended,
            let ______ = self.current_user_is_followed_by,
            let _______ = self.current_user_is_pending_followed_by,
            let ________ = self.current_user_blocks
        else {
            return false
        }
        return true
    }
}

//
//let is_following = user.current_user_is_following,
//let is_pending_following = user.current_user_is_pending_following,
//let is_friending = user.current_user_is_friending,
//let is_pending_friending = user.current_user_is_pending_friending,
//let is_pending_friended = user.current_user_is_pending_friended,
//let is_followed_by = user.current_user_is_followed_by,
//let is_pending_followed_by = user.current_user_is_pending_followed_by,
//let blocks = user.current_user_blocks

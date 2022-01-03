//
//  CovetUserRelationship.swift
//  Covet
//
//  Created by Brendan Manning on 1/2/22.
//

import Foundation

enum CovetUserRelationshipType {
    case Following
    case Friends
    case Blocks
}

//class CovetUserRelationship {
//    private(set) var user: CovetUser;
//    private(set) var other: Int;
//    private(set) var relationshipType: CovetUserRelationshipType;
//
//    init(user: CovetUser, other: Int, relationshipType: CovetUserRelationshipType) {
//        self.user = user
//        self.other = other
//        self.relationshipType = relationshipType
//    }
//
//    static func from(userFollowing: CovetUserFollowingRelationship) -> CovetUserRelationship {
//        return CovetUserRelationship(user: userFollowing.user, other: userFollowing.follows, relationshipType: .Following)
//    }
//
//    static func from(userFollowing: CovetUserFriendshipRelationship) -> CovetUserRelationship {
//        return CovetUserRelationship(user: userFollowing.user, other: userFollowing.befriends, relationshipType: .Friends)
//    }
//
//}

class CovetUserRelationship : Decodable {
    private(set) var user: CovetUser;
    private(set) var other: CovetUser;
    private(set) var relationship: String;
    private(set) var pending: Bool;
}

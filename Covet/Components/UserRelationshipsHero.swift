//
//  UserRelationshipsHero.swift
//  Covet
//
//  Created by Covet on 1/13/22.
//

import SwiftUI

struct UserRelationshipsHero: View {
    
    var following: [CovetUserRelationshipInfo]?
    var followers: [CovetUserRelationshipInfo]?
    var friends: [CovetUserRelationshipInfo]?
    
    var following_count: Int?
    var followers_count: Int?
    var friends_count: Int?
    
    init(following: [CovetUserRelationshipInfo], followers: [CovetUserRelationshipInfo], friends: [CovetUserRelationshipInfo]) {
        self.following = following
        self.followers = followers
        self.friends = friends
    }
    
    init(following_count: Int, followers_count: Int, friends_count: Int) {
        self.following_count = following_count
        self.followers_count = followers_count
        self.friends_count = friends_count
    }
    
    var pending: [CovetUserRelationshipInfo]?
    
    var body: some View {
        HStack {
            if shouldShowFollowerCount() {
                NavigationLink(
                    destination: UserManagerView(
                        relationships: followers,
                        navbarTitle: "Followers"
                    )) {
                    VStack {
                        Text(String(followerCount()))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        Text("followers")
                    }
                }
            }
            if shouldShowFollowingCount() {
                NavigationLink(
                    destination: UserManagerView(
                        relationships: following,
                        navbarTitle: "Following"
                    )) {
                    VStack {
                        Text(String(followingCount()))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        Text("following")
                    }
                }
            }
            if shouldShowFriendCount() {
                NavigationLink(
                    destination: UserManagerView(
                        relationships: friends,
                        navbarTitle: "Friends"
                    )) {
                    VStack {
                        Text(String(friendCount()))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        Text("friends")
                    }
                }
            }
        }
        .frame(width: nil, height: 60, alignment: .top)
    }
    
    func shouldShowFollowerCount() -> Bool {
        return followers != nil || followers_count != nil
    }
    func followerCount() -> Int {
        if let f = followers {
            return f.count
        }
        return followers_count!
    }
    func shouldShowFollowingCount() -> Bool {
        return following != nil || following_count != nil
    }
    func followingCount() -> Int {
        if let f = following {
            return f.count
        }
        return following_count!
    }
    func shouldShowFriendCount() -> Bool {
        return friends != nil || friends_count != nil
    }
    func friendCount() -> Int {
        if let f = friends {
            return f.count
        }
        return friends_count!
    }
}

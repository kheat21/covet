//
//  UserRelationshipsHero.swift
//  Covet
//
//  Created by Covet on 1/13/22.
//

import SwiftUI

struct UserRelationshipsHero: View {
    
    var following: [CovetUserRelationshipInfo]
    var followers: [CovetUserRelationshipInfo]
    var friends: [CovetUserRelationshipInfo]
    var pending: [CovetUserRelationshipInfo]?
    
    var body: some View {
        HStack {
            NavigationLink(
                destination: UserManagerView(relationshipTypes: [UserRelationshipSearchType.FRIENDS])
            ) {
                VStack {
                    Text(String(followers.count))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("followers")
                }
            }
            NavigationLink(
                destination: UserManagerView(relationshipTypes: [UserRelationshipSearchType.FOLLOWINGS])
            ) {
                VStack {
                    Text(String(following.count))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("following")
                }
            }
            NavigationLink(
                destination: UserManagerView(relationshipTypes: [UserRelationshipSearchType.FRIENDS])) {
                VStack {
                    Text(String(friends.count))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("friends")
                }
            }
        }
        .frame(width: nil, height: 60, alignment: .top)
    }
}

struct UserRelationshipsHero_Previews: PreviewProvider {
    static var previews: some View {
        UserRelationshipsHero(
            following: [],
            followers: [],
            friends: []
        )
    }
}

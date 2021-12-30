//
//  UserManagerView.swift
//  Covet
//
//  Created by Brendan Manning on 12/28/21.
//

import Foundation
import SwiftUI

enum UserRelationshipSearchType {
    case FRIENDS
    case FOLLOWERS
    case FOLLOWINGS
    case PENDING
}

struct UserManagerView: View {

    @State private var relationshipTypes: [UserRelationshipSearchType] = []
    @State private var searchText = ""
    
    init(relationshipTypes: [UserRelationshipSearchType]) {
        self.relationshipTypes = relationshipTypes
    }
    
    private var users: [CovetUser] = [
        CovetUser.getSampleUser(number: 1, privateForFollowing: true, privateForFriending: false),
        CovetUser.getSampleUser(number: 2, privateForFollowing: false, privateForFriending: false)
    ]
    
    var body: some View {
        
            VStack {
                SearchBar(text: $searchText)
                List(
                    users.filter({ searchText.isEmpty ? true : $0.getDisplayItem().contains(searchText) })
                ) { item in
                    UserListItem(user: item)
                        
                }
                .listStyle(PlainListStyle())
                
            }
            .navigationBarTitle("Friends", displayMode: .inline)
            
    }

}

struct UserManagerView_Previews: PreviewProvider {
    static var previews: some View {
        UserManagerView(relationshipTypes: [])
    }
}

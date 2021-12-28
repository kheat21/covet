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
        CovetUser(uid: "123"),
        CovetUser(uid: "456")
    ]
    
    var body: some View {
        ZStack {
            VStack {
                
                SearchBar(text: $searchText).padding(.top, 0)
                List(
                    users.filter({ searchText.isEmpty ? true : $0.getDisplayItem().contains(searchText) })
                ) { item in
                    UserListItem(user: item)
                }
            }

        }
    }

}

struct UserManagerView_Previews: PreviewProvider {
    static var previews: some View {
        UserManagerView(relationshipTypes: [])
    }
}

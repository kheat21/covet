//
//  UserManagerView.swift
//  Covet
//
//  Created by Brendan Manning on 12/28/21.
//

import AlertToast
import Combine
import ManagedSettings
import SwiftUI

enum UserRelationshipSearchType {
    case FRIENDS
    case FOLLOWERS
    case FOLLOWINGS
    case PENDING
}

struct UserManagerView: View {

    @State var relationships: [CovetUserRelationshipInfo]?
    @State var navbarTitle: String?
    
//    @Binding var shouldShowSavingToast: Bool
//    @Binding var shouldShowErrorToast: Bool
//    @Binding var errorToastContents: String
    
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText)
            Spacer().frame(height: 16)
            ScrollView {
                ForEach(self.getFilteredRelationships(), id: \.self) { item in
                    UserListItem(
                        user: item.user,
                        clickable: false,
                        showRelationshipToUser: false,
                        showPendingOptions: true //,
//                        shouldShowSavingToast: $shouldShowSavingToast,
//                        shouldShowErrorToast: $shouldShowErrorToast,
//                        errorToastContents: $errorToastContents
                    )
                }
                .listStyle(PlainListStyle())
            }
            Spacer()
        }
        .navigationBarTitle(self.navbarTitle ?? "User Management", displayMode: .inline)
//        .toast(isPresenting: $shouldShowSavingToast, alert: {
//            AlertToast(type: .loading, title: nil, subTitle: nil)
//        })
//        .toast(isPresenting: $shouldShowErrorToast, alert: {
//            AlertToast(displayMode: .hud, type: .error(Color.red), title: self.errorToastContents)
//        })
    }
    
    func getFilteredRelationships() -> [CovetUserRelationshipInfo] {
        if let rels = self.relationships {
            let res = rels.filter { relationshipInfo in
                if searchText.isEmpty {
                    return true
                }
                return (
                    (relationshipInfo.user.name ?? "").contains(searchText) ||
                    relationshipInfo.user.username.contains(searchText)
                )
            }
            print(res)
            return res
        }
        return []
    }
}

/*
struct UserManagerViewOld: View {

    @State private var relationshipTypes: [UserRelationshipSearchType] = []
    @State private var searchText = ""
    
    @State private var networkError: Bool = false
    @State private var internalAPIError: Bool = false
    
    @State private var shouldShowLoadingToast: Bool = true
    @State private var _users: [CovetUser]?
    
    init(relationshipTypes: [UserRelationshipSearchType]) {
        self.relationshipTypes = relationshipTypes
    }
    
    var body: some View {
        VStack {
            if let users = self._users {
                SearchBar(text: $searchText)
                List(
                    users.filter({ searchText.isEmpty ? true : $0.username.contains(searchText) })
                ) { item in
                    UserListItem(user: item)
                    
                }
                .listStyle(PlainListStyle())
            }
            
        }
        .navigationBarTitle("Friends", displayMode: .inline)
        .toast(isPresenting: $shouldShowLoadingToast, alert: {
            AlertToast(type: .loading, title: nil, subTitle: nil)
        })
        .task {
            print("Trying to get relationships...")
            do {
                if let relationships = try await API.getRelationships() {
                    self._users = getMatchingUsers(
                        me: try await AuthService.shared.getUser()!,
                        relationships: relationships,
                        relationshipTypes: self.relationshipTypes
                    )
                    self.shouldShowLoadingToast = false
                } else {
                    print("Unable to call API")
                }
            } catch {
                print(error)
            }
        }
    }
}
func getMatchingUsers(me: CovetUser, relationships: [CovetUserRelationship], relationshipTypes: [UserRelationshipSearchType]) -> [CovetUser] {
    
    return []

    let include_my_friends = relationshipTypes.contains(UserRelationshipSearchType.FRIENDS)
    let include_my_followers = relationshipTypes.contains(UserRelationshipSearchType.FOLLOWERS)
    let include_who_i_follow = relationshipTypes.contains(UserRelationshipSearchType.FOLLOWINGS)
    
    print("include_my_friends: " + String(include_my_friends))
    print("include_my_followers: " + String(include_my_followers))
    print("include_who_i_follow: " + String(include_who_i_follow))
    
    let rels: [CovetUserRelationship?] = relationships
    
    let users: [CovetUser?] = rels
        .map { rel in
            if (rel!.relationship == "FRIEND" && include_my_friends) {
                return rel!.other
            }
            else if (rel!.relationship == "FOLLOWING" && rel!.user.id == me.id && include_who_i_follow) {
                return rel!.other
            }
            else if (rel!.relationship == "FOLLOWING" && rel!.other.id == me.id && include_my_followers) {
                return rel!.user
            }
            return nil
        }
        .filter { rel in
            return rel != nil
        }
    
    return users as! [CovetUser]

}
 */
/*
func getPendingUsers(relationships: [CovetUserRelationship]) -> [CovetUser] {
    return relationships
        .filter { rel in
            return rel.pending
        }
        .map { rel in
            return rel.other
        }
}
*/

/*
func getMatchingUsers(relationships: [CovetUserRelationship], relationshipTypes: [UserRelationshipSearchType]) -> [CovetUser] {
    
    let FRIENDSHIP_APPROVED = "FRIENDSHIP_APPROVED"
    let FRIENDSHIP_WAITING = "FRIENDSHIP_WAITING"
    let FRIENDSHIP_DECLINED = "FRIENDSHIP_DECLINED"
    let FOLLOWING_APPROVED = "FOLLOWING_APPROVED"
    let FOLLOWING_WAITING = "FOLLOWING_WAITING"
    let FOLLOWING_DECLINED = "FOLLOWING_DECLINED"
    
    
    var users: [CovetUser] = []
    
    relationships.friends.forEach { friendshipRelationship in
        if friendshipRelationship.status == FRIENDSHIP_APPROVED && relationshipTypes.contains(.FRIENDS) {
            users.append(friendshipRelationship.user)
        }
        //  else if friendshipRelationship.status == FRIENDSHIP_WAITING && relationshipTypes.contains(.PENDING) {
        //      users.append(friendshipRelationship.user)
        //  }
    }
    
    relationships.follows.forEach { followingRelationship in
        if followingRelationship.status == FOLLOWING_APPROVED && relationshipTypes.contains(.FOLLOWERS) {
            users.append(followingRelationship.user)
        }
        // else if followingRelationship.status == FOLLOWING_WAITING && relationships.contains(.PENDING) {
        //    users.append()
        // }
    }
    
    return users
}
 */

//struct UserManagerView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserManagerView(relationshipTypes: [])
//    }
//}

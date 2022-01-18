//
//  UserListItem.swift
//  Covet
//
//  Created by Brendan Manning on 12/28/21.
//

import AlertToast
import SwiftUI

struct UserListItem: View {
        
    @State var backgroundColor: Color = Color.white;
    @State var showingActionDialog: Bool = false;
    @State var user: CovetUser;
    
    @State var showRelationshipManagementFailedToast: Bool = false;
    
    var body: some View {
        HStack {
            CovetC(size: 48)
//            Text(user.getDisplayItem())
            Text(user.username)
            Spacer()
            if let chipContents = getChipContents(user: user) {
                Chip(
                    preIcon: chipContents.icon,
                    text: chipContents.text,
                    color: Color.accentColor
                )
            }
        }
        .onLongPressGesture(perform: {
            if let currentUser = AuthService.shared.currentCovetUser {
                if currentUser.id == user.id {
                    return
                }
            }
            showingActionDialog = true
        })
        .confirmationDialog("Manage User", isPresented: $showingActionDialog) {
            if !user.currentUserFollows() && !user.currentUserFriend() {
                followButton(user: user)
            }
            if !user.currentUserFriend() {
                befriendButton(user: user)
            }
            blockButton(user: user)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("@" + user.username)
        }
        .toast(isPresenting: $showRelationshipManagementFailedToast) {
            AlertToast(type: .error(Color.red), title: "Oops!", subTitle: "We weren't able to make your profile")
        }
    }

    struct ChipContents {
        var text: String
        var icon: String?
    }
    
    func getChipContents(user: CovetUser) -> ChipContents? {
        guard user.allRelationshipInformationPresent() else {
            return nil
        }
        
        var text: String? = nil
        var icon: String? = nil
        
        if user.currentUserBlocks() {
            text = "BLOCKED"
            icon = "hand.raised"
        }
        
        if user.currentUserFriend() {
            text = "FRIENDS"
            icon = "person.2"
        }
        
        if user.currentUserFollows() && user.currentUserFollowedBy() {
            text = "FOLLOW"
            icon = "arrow.right.arrow.left"
        }
        
        if user.currentUserFollows() && !user.currentUserFollowedBy() {
            text = "FOLLOW"
            icon = "arrow.right"
        }
        
        if !user.currentUserFollows() && user.currentUserFollowedBy() {
            text = "FOLLOWED BY"
            icon = "arrow.left"
        }
        
        if user.currentUserPendingOutgoing() {
            text = "PENDING"
            icon = "hourglass"
        }
        
        if text != nil {
            return ChipContents(
                text: text!,
                icon: icon
            )
        }
            
        return nil
        
    }
    
    func blockButton(user: CovetUser) -> some View {
        return Button("Block") {
            doUserManagement(user: user, relationshipType: .Blocks)
        }
    }
    
    func followButton(user: CovetUser) -> some View {
        return Button("Follow") {
            doUserManagement(user: user, relationshipType: .Following)
        }
    }
    
    func befriendButton(user: CovetUser) -> some View {
        return Button("Friend") {
            doUserManagement(user: user, relationshipType: .Friends)
        }
    }
    
    func doUserManagement(user: CovetUser, relationshipType: CovetUserRelationshipType) {
        Task {
            do {
                print("Setting relationship...")
                let resp = try await API.setRelationship(userId: user.id, relationshipType: relationshipType)
                if let response = resp {
                    self.user = response.otherUser
                } else {
                    print("No relation obtained")
                }
            } catch {
                showRelationshipManagementFailedToast = true
            }
        }
    }
}

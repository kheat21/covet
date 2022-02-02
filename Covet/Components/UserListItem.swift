//
//  UserListItem.swift
//  Covet
//
//  Created by Brendan Manning on 12/28/21.
//

import AlertToast
import SwiftUI

struct UserListItem: View {
    
    @EnvironmentObject var auth: AuthService
        
    @State var backgroundColor: Color = Color.white;
    @State var showingActionDialog: Bool = false;
    
    @State var user: CovetUser;
    @State var relationship: CovetUserRelationship?;
    @State var clickable: Bool = true
    @State var showRelationshipToUser: Bool = true
    @State var showPendingOptions: Bool = false
    
    var onListItemRemoved: (() -> Void)? = nil
    
    @State var isSaving: Bool = false
    
    @State private var navigateToUserView: Bool = false
    @State private var navigateToUserId: Int = -1
    
    var body: some View {
        NavigationLink(isActive: self.$navigateToUserView, destination: {
            ProfileView(id: self.navigateToUserId)
        }, label: {
            EmptyView()
        })
        HStack {
            Spacer().frame(width: 16)
            CovetC(size: 48)
//            Text(user.getDisplayItem())
            Text(user.username)
            Spacer()
            if !self.isSaving {
                if self.showRelationshipToUser {
                    if let chipContents = getChipContents(user: user) {
                        Chip(
                            preIcon: chipContents.icon,
                            text: chipContents.text,
                            color: Color.accentColor
                        )
                    }
                }
                if self.showPendingOptions {
                    Chip(preIcon: "person.crop.circle.badge.xmark", text: "REJECT", color: Color.gray)
                        .onTapGesture {
                            doActOnPendingRequest(value: false)
                        }
                    Chip(preIcon: "person.badge.plus", text: "ACCEPT", color: Color.covetGreen())
                        .onTapGesture {
                            doActOnPendingRequest(value: true)
                        }
                }
            } else {
                ProgressView()
            }
            Spacer().frame(width: 16)
        }
        .onTapGesture {
            if self.clickable && !self.isSaving {
                self.navigateToUserId = user.id
                self.navigateToUserView = true
            }
        }
        .onLongPressGesture(perform: {
            if !self.isSaving {
                if let currentUser = auth.currentCovetUser {
                    if currentUser.id == user.id {
                        return
                    }
                }
                showingActionDialog = true
            }
        })
        .confirmationDialog("Manage User", isPresented: $showingActionDialog) {
            if user.allRelationshipInformationPresent() {
                if !user.currentUserFollows() && !user.currentUserFriend() {
                    followButton(user: user)
                }
                if !user.currentUserFriend() {
                    befriendButton(user: user)
                }
                blockButton(user: user)
                Button("Cancel", role: .cancel) { }
            }
        } message: {
            Text("@" + user.username)
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
        if self.isSaving { return }
        self.isSaving = true
        Task {
            do {
                print("Setting relationship...")
                let resp = try await API.setRelationship(userId: user.id, relationshipType: relationshipType)
                if let response = resp {
                    self.user = response.otherUser
                    await auth.refreshUser()
                } else {
                    print("No relation obtained")
                }
            } catch {
//                self.shouldShowErrorToast = true
//                self.errorToastContents = "Try again later"
            }
            self.isSaving = false
        }
    }
    
    func doActOnPendingRequest(value: Bool) {
        print("Doing action")
        self.isSaving = true
        Task {
            let success = await actOnPendingRequest(value: value)
            if success {
                await auth.refreshUser()
            }
            self.isSaving = false
            if let removedCallback = self.onListItemRemoved {
                removedCallback()
            }
        }
    }
    
    func actOnPendingRequest(value: Bool) async -> Bool {
        if let rel = self.relationship {
            do {
                if let resp = try await API.actOnPending(id: rel.id, accept: value) {
                    print(resp)
                    return resp.success
                } else {
                    print("No resp")
                }
            } catch {
                print("The error was")
                print(error)
            }
        } else {
            print("No relationship available")
        }
        return false
    }
}

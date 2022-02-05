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
    
    @State private var navigateToUserProfile: Bool = false
    @State private var navigateToUser: CovetUser? = nil
    
    var body: some View {
        NavigationLink(isActive: self.$navigateToUserProfile, destination: {
            if let usr = self.navigateToUser {
                ProfileView(userId: usr.id)
                    .navigationBarTitle(usr.username)
            } else {
                EmptyView()
            }
        }, label: {
            EmptyView()
        })
        HStack {
            Spacer().frame(width: 16)
            makeCovetC(size: 48, user: self.user)
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
                        .foregroundColor(Color.white)
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
        .background { Color.white }
//        .background {
//            NavigationLink(isActive: self.$navigateToUserProfile, destination: {
//                ProfileView(userId: self.navigateToUser!.id)
//            }, label: {
//                EmptyView()
//            })
//        }
        .onTapGesture {
            print("Tapped")
            if self.clickable && !self.isSaving {
                self.navigateToUser = user
                self.navigateToUserProfile = true
                // print("Navigate to " + String(self.navigateToUser.id))
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
//        .sheet(item: $navigateToUser) { item in
//            ProfileView(userId: item.id)
//        }
        .confirmationDialog("Manage User", isPresented: $showingActionDialog) {
            if user.allRelationshipInformationPresent() {
                if !hasPendingRequestOutgoing() {
                    if !user.currentUserFollows() && !user.currentUserFriend() {
                        followButton(user: user)
                        befriendButton(user: user)
                    }
                    if user.currentUserFollows() || user.currentUserFriend() {
                        removeButton()
                    }
                } else {
                    cancelPendingButton()
                }
            }
            blockButton(user: user)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("@" + user.username)
        }
    }

    struct ChipContents {
        var text: String
        var icon: String?
    }
    
    func blockButton(user: CovetUser) -> some View {
        return Button("Block", role: .destructive) {
            doUserManagement(user: user, relationshipType: .Blocks)
        }
    }
    
    func followButton(user: CovetUser) -> some View {
        return Button("Follow") {
            doUserManagement(user: user, relationshipType: .Following)
        }
    }
    
    func befriendButton(user: CovetUser) -> some View {
        return Button(AppConfig.FRIEND_TIER_ALIAS) {
            doUserManagement(user: user, relationshipType: .Friends)
        }
    }
    
    func removeButton() -> some View {
        return Button("Remove", role: .destructive) {
            doRemoveRelationships(user: user)
        }
    }
    
    func cancelPendingButton() -> some View {
        return Button("Cancel pending request", role: .none) {
            doRemoveRelationships(user: user)
        }
    }
    
    func doUserManagement(user: CovetUser, relationshipType: CovetUserRelationshipType) {
        if self.isSaving { return }
        Task.detached {
            await updateUIForUserManagement(saving: true, user: nil)
            do {
                print("Setting relationship...")
                let resp = try await API.setRelationship(userId: user.id, relationshipType: relationshipType)
                if let response = resp {
                    await updateUIForUserManagement(saving: false, user: response.otherUser)
                } else {
                    await updateUIForUserManagement(saving: false, user: nil)
                }
            } catch {
                await updateUIForUserManagement(saving: false, user: nil)
            }
        }
    }
    
    @MainActor
    func updateUIForUserManagement(saving: Bool, user: CovetUser?) {
        self.isSaving = saving
        if let u = user {
            self.auth.refreshUser()
            self.user = u
        }
        self.showRelationshipToUser = true
    }
    
    func doRemoveRelationships(user: CovetUser) {
        if self.isSaving { return }
        Task.detached {
            await updateUIForRemoveRelationshipRequest(saving: true, success: nil)
            var success = false
            do {
                if let resp = try await API.removeRelationshipWith(userId: user.id) {
                    success = resp.success
                    if success {
                        await auth.refreshUser()
                    }
                }
            } catch {}
            await updateUIForRemoveRelationshipRequest(saving: false, success: success)
        }
    }
    
    func doRemoveRelationship(relationship: CovetUserRelationship) {
        if self.isSaving { return }
        Task.detached {
            await self.setLoading(value: true)
            var success = false
            do {
                print("Removing relationship...")
                if let resp = try await API.removeRelationship(relationshipId: relationship.id) {
                    success = resp.success
                }
            } catch {}
            await self.updateUIForRemoveRelationshipRequest(saving: false, success: success)
            await callItemRemovedListener()
        }
    }
    
    @MainActor
    func updateUIForRemoveRelationshipRequest(saving: Bool, success: Bool?) async {
        print("updateUIForRemoveRelationshipRequest")
        self.isSaving = saving
        if success == true {
            print("IN success==true")
            self.auth.refreshUser()
            self.relationship = nil
            self.user.current_user_is_following = 0
            self.user.current_user_is_followed_by = 0
            self.user.current_user_is_friending = 0
            self.showRelationshipToUser = false
        }
    }
    
    @MainActor
    func callItemRemovedListener() {
        if let removedCallback = self.onListItemRemoved {
            removedCallback()
        }
    }
    
    func doActOnPendingRequest(value: Bool) {
        print("Doing action")
        self.isSaving = true
        Task {
            let success = await actOnPendingRequest(value: value)
            if success {
                await auth.refreshUser()
                if let removedCallback = self.onListItemRemoved {
                    removedCallback()
                }
            }
            self.isSaving = false
        }
    }
    
//    func doCancelPendingRequest() {
//        Task.detached {
//            await self.setLoading(value: true)
//
//            var success = false
//
//            if let rel = self.relationship {
//                if let res = try await API.removeRelationship(relationshipId:  rel.id) {
//                    success = res.success
//                }
//            }
//            if success {
//                await auth.refreshUser()
//            }
//            await self.setLoading(value: false)
//        }
//    }
    
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
    
    func hasPendingRequestOutgoing() -> Bool {
        if let rel = self.relationship {
            return rel.pending == 1
        }
        return (
            self.user.current_user_is_pending_following == 1 ||
            self.user.current_user_is_pending_friending == 1
        )
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
            text = AppConfig.FRIEND_TIER_ALIAS
            icon = AppConfig.FRIEND_TIER_ICON
        }
        
        if user.currentUserFollows() && user.currentUserFollowedBy() {
            text = AppConfig.FOLLOWER_TIER_ALIAS
            icon = AppConfig.FOLLOWER_TIER_ICON_FILLED
        }
        
        if user.currentUserFollows() && !user.currentUserFollowedBy() {
            text = AppConfig.I_FOLLOW_ALIAS
            icon = AppConfig.FOLLOWER_TIER_ICON
        }
        
        if !user.currentUserFollows() && user.currentUserFollowedBy() {
            text = AppConfig.FOLLOWS_ME_ALIAS
            icon = AppConfig.FOLLOWER_TIER_ICON
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
    
    @MainActor func setLoading(value: Bool) {
        self.isSaving = value
    }
}

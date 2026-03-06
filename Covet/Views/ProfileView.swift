//
//  ProfileView.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import AlertToast
import SwiftUI
import Firebase
import SwiftUITooltip

struct ProfileView: View {

    // Shared auth state
    @EnvironmentObject var auth: AuthService
    
    // What we check to see if a network call should be made
    var profilePageMode: Bool = false
    var userId: Int? = -1
    
    // What is actually presented
    @State var user: CovetUser? = nil
    
    // Current UI state
    @State var isLoading: Bool = false
    @State var hadError: Bool = false
    
    @State var showPostInDetailView: Post? = nil
    @State var showManagerView: Bool = false
    
    @State var showTooltipIfApplicable: Bool = true
    var tooltipConfig = DefaultTooltipConfig()
    
    init(isMe: Bool) {
        if !isMe {
            fatalError("Cannot use this constructor unless the value is true")
        }
        self.profilePageMode = true
        tooltipConfig.backgroundColor = Color.covetGreen()
        tooltipConfig.side = .leading
        tooltipConfig.borderColor = Color.clear
        tooltipConfig.arrowHeight = 6.0
    }
    
    init(userId: Int) {
        self.userId = userId
        self.profilePageMode = false
    }

    var body : some View {
        ZStack {
            if self.profilePageMode == true {
                NavigationView {
                    if let me = auth.currentCovetUser {
//                        NavigationLink(isActive: self.$showManagerView, destination: {
//                            HamburgerOptionsView(user: me)
//                        }, label: {
//                            EmptyView()
//                        })
//                            .frame(width: 0, height: 0, alignment: Alignment.topTrailing)
//                            .padding(0)
                        UserProfile(user: me)
                            .navigationBarHidden(false)
                            .navigationBarTitle(auth.currentCovetUser?.username ?? "My Profile")
                            .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
                            .navigationBarItems(
                                leading: makeCovetC(size: 36, user: me, textSize: 12),
                                trailing: HStack {
                                    RefreshUserButton()
                                    NavigationLink(isActive: self.$showManagerView, destination: {
                                        HamburgerOptionsView(user: me)
                                    }, label: {
                                        if me.countPendingIncoming() > 0 && self.showTooltipIfApplicable {
                                            Image(systemName: "line.horizontal.3")
                                                .overlay(
                                                    ButtonBadge(message: "!!")
                                                )
                                                
                                        } else {
                                            Image(systemName: "line.horizontal.3")
                                                .zIndex(3)
                                        }
                                    })
                                }
//                                trailing: Button(
//                                    action: {
//                                        self.showManagerView = true
//                                    }
//                                )
//                                {
//                                    Image(systemName: "line.horizontal.3")
//                                }
                            )
                    } else {
                        ProgressView()
                    }
                }
            } else {
                
                if let them = self.user {
                    UserProfile(user: them)
                        .toast(isPresenting: $isLoading, alert: {
                            AlertToast(displayMode: .alert, type: .loading, title: nil)
                        })
                        .toast(isPresenting: $hadError, alert: {
                            AlertToast(displayMode: .hud, type: .error(Color.red), title: "Error getting user")
                        })
                } else {
                    ProgressView()
                        .onAppear {
                            doPopulateRemoteUser()
                        }
                }
            }
            
        }
        
    }
    
    private func doPopulateRemoteUser() {
        Task.detached {
            await self.makeUI(loading: true, user: nil)
            var user: CovetUser? = nil
            do {
                let resp = try await API.getUser(user_id: self.userId)
                if let r = resp {
                    user = r.user
                }
            } catch {}
            await self.makeUI(loading: false, user: user)
        }
    }
    
    @MainActor
    private func makeUI(loading: Bool, user: CovetUser?) async {
        self.user = user
        self.isLoading = loading
        self.hadError = !loading && user == nil
    }
    
}


struct UserProfile : View {
    
    @EnvironmentObject var auth: AuthService
    
    var user: CovetUser;
    
    @State var showPostInDetailView: Post? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            ProfileHeaderSection(user: user, isOwnProfile: isOwnProfile())

            if let posts = user.posts {
                if posts.count == 0 {
                    UserProfileNoPostsYet(isOwnProfile: self.isOwnProfile())
                } else {
                    HStack {
                        Text("My Covet List")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        Spacer()
                    }
                    ScrollView {
                        ImageGrid(images: posts) { i in
                            self.showPostInDetailView = i
                        }
                    }
                }
            }
        }
        .sheet(item: self.$showPostInDetailView, onDismiss: {
            self.showPostInDetailView = nil
        }, content: { p in
            PostView(post: p, isOwnPost: self.isOwnProfile())
        })
    }
    
    private func isOwnProfile() -> Bool {
        if let currentUser = self.auth.currentCovetUser {
            if currentUser.id == user.id {
                return true
            }
        }
        return false
    }
}

private struct ProfileHeaderSection: View {
    var user: CovetUser
    var isOwnProfile: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                makeCovetC(size: 72, user: user, textSize: 24)
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.username)
                        .font(.title3)
                        .fontWeight(.semibold)
                    if let address = user.address, !address.isEmpty {
                        Text(address)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            HStack(spacing: 0) {
                ProfileStatColumn(value: user.followers_count ?? 0, label: "FOLLOWERS")
                ProfileStatColumn(value: user.follows_count ?? 0, label: "FOLLOWING")
                ProfileStatColumn(value: user.posts?.count ?? 0, label: "COVETING")
            }
            .padding(.bottom, 16)

            if isOwnProfile {
                HStack(spacing: 12) {
                    NavigationLink(destination: UserSettingsView(mode: .Modify, handle: user.username, name: user.name ?? "")) {
                        Text("Edit Profile")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.covetGreen())
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    Button(action: {}) {
                        Text("Share Wishlist")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(UIColor.systemGray6))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }

            Divider()
        }
    }
}

private struct ProfileStatColumn: View {
    var value: Int
    var label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal))
                .font(.system(size: 22, weight: .regular, design: .serif))
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }
}

struct UserProfileNoPostsYet : View {
    var isOwnProfile: Bool
    var body : some View {
        Spacer()
        VStack {
            Text("No posts yet.")
            if isOwnProfile {
                Group {
                    Text("Add something with the ").foregroundColor(Color.black) +
                    Text("covet").foregroundColor(Color.covetGreen()) +
                    Text(". button in Safari").foregroundColor(Color.black)
                }
                .multilineTextAlignment(.center)
            }
        }
//        Text("No posts yet. Add something with the covet button in Safari to make one!")
//            .padding([.leading, .trailing], 64)
//            .multilineTextAlignment(.center)
        Spacer()
    }
}

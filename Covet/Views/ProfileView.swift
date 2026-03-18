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
    
    init() {
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
                            .navigationBarHidden(true)
                    } else {
                        ProgressView()
                    }
                }
            } else {
                
                if let them = self.user {
                    UserProfile(user: them)
                        .navigationBarHidden(true)
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
    @State var showSizes: Bool = false
    @State private var liveIsFollowing: Bool = false

    private var canSeeSizes: Bool {
        guard !isOwnProfile() else { return false }
        guard hasSizes else { return false }
        return liveIsFollowing
    }

    private var hasSizes: Bool {
        [user.shoe_size, user.ring_size, user.jeans_size, user.dress_size, user.top_size]
            .contains { $0 != nil && !($0!.isEmpty) }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ProfileHeaderSection(user: user, isOwnProfile: isOwnProfile(), liveIsFollowing: $liveIsFollowing)

                if let posts = user.posts {
                    if posts.count == 0 {
                        UserProfileNoPostsYet(isOwnProfile: self.isOwnProfile())
                    } else {
                        Section(header:
                            HStack(spacing: 8) {
                                Text(covetListTitle())
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                if canSeeSizes {
                                    Button(action: { showSizes = true }) {
                                        Image(systemName: "ruler.fill")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color.covetGreen())
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(UIColor.systemBackground))
                        ) {
                            ImageGrid(images: posts) { i in
                                self.showPostInDetailView = i
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSizes) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("\(user.name?.components(separatedBy: " ").first ?? user.username)'s Sizes")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Button(action: { showSizes = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(UIColor.systemGray3))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)
                MySizesReadOnlySection(user: user)
                    .padding(.horizontal, 20)
                Spacer()
            }
            .presentationDetentsMediumIfAvailable()
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

    private func covetListTitle() -> String {
        if isOwnProfile() {
            return "My Covet List"
        }
        let firstName = user.name?.components(separatedBy: " ").first ?? user.username
        return "\(firstName)'s Covet List"
    }
}

private struct ProfileHeaderSection: View {
    var user: CovetUser
    var isOwnProfile: Bool
    @Binding var liveIsFollowing: Bool
    @Environment(\.presentationMode) var presentationMode

    @State private var isFollowing: Bool = false
    @State private var isPending: Bool = false
    @State private var followLoading: Bool = false
    @State private var didInitFollowState: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var showManagerView: Bool = false

    @State private var showFollowers: Bool = false
    @State private var showFollowing: Bool = false

    private var followerUsers: [CovetUser] {
        (user.followers ?? []).map { $0.user }
    }
    private var followingUsers: [CovetUser] {
        (user.follows ?? []).map { $0.user }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                if !isOwnProfile {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .accessibilityLabel("Back")
                }
                makeCovetC(size: 72, user: user, textSize: 24)
                VStack(alignment: .leading, spacing: 2) {
                    if let name = user.name, !name.isEmpty {
                        Text(name)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("@\(user.username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text(user.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                Spacer()
                if isOwnProfile {
                    NavigationLink(isActive: $showManagerView, destination: {
                        HamburgerOptionsView(user: user)
                    }, label: {
                        Image(systemName: "line.horizontal.3")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .overlay(
                                user.countPendingIncoming() > 0
                                    ? AnyView(ButtonBadge(message: "!!"))
                                    : AnyView(EmptyView())
                            )
                    })
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            HStack(spacing: 0) {
                NavigationLink(isActive: $showFollowers, destination: {
                    FollowersFollowingListView(title: "Followers", users: followerUsers)
                }, label: { EmptyView() })
                NavigationLink(isActive: $showFollowing, destination: {
                    FollowersFollowingListView(title: "Following", users: followingUsers)
                }, label: { EmptyView() })

                ProfileStatColumn(value: user.followers_count ?? 0, label: "FOLLOWERS")
                    .onTapGesture { showFollowers = true }
                ProfileStatColumn(value: user.follows_count ?? 0, label: "FOLLOWING")
                    .onTapGesture { showFollowing = true }
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
                    Button(action: { showShareSheet = true }) {
                        Text("Share Covet List")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(UIColor.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }
                    .sheet(isPresented: $showShareSheet) {
                        PostShareSheet(activityItems: ["Check out my Covet List: @\(user.username)"])
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            } else {
                // Follow button for other users
                Button(action: { toggleFollow() }) {
                    Group {
                        if followLoading {
                            ProgressView().tint(.white)
                        } else if isFollowing {
                            Text("Following")
                        } else if isPending {
                            Text("Requested")
                        } else {
                            Text("Follow")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isFollowing || isPending ? Color(UIColor.systemGray6) : Color.covetGreen())
                    .foregroundColor(isFollowing || isPending ? .black : .white)
                    .cornerRadius(8)
                }
                .disabled(followLoading)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }

            Divider()
        }
        .onAppear {
            if !didInitFollowState {
                isFollowing = (user.current_user_is_following ?? 0) == 1
                isPending   = (user.current_user_is_pending_following ?? 0) == 1
                liveIsFollowing = isFollowing
                didInitFollowState = true
            }
        }
    }

    private func toggleFollow() {
        followLoading = true
        Task {
            do {
                if isFollowing || isPending {
                    let _ = try await API.removeRelationshipWith(userId: user.id)
                    await MainActor.run { isFollowing = false; isPending = false; liveIsFollowing = false }
                } else {
                    let _ = try await API.setRelationship(userId: user.id, relationshipType: .Following)
                    // If user has private following, it becomes pending; otherwise approved
                    let nowPending = user.privateForFollowing == 1
                    await MainActor.run {
                        isFollowing = !nowPending
                        isPending   = nowPending
                        liveIsFollowing = !nowPending
                    }
                }
            } catch {
                print("Follow error: \(error)")
            }
            await MainActor.run { followLoading = false }
        }
    }
}

private struct MySizesReadOnlySection: View {
    var user: CovetUser

    private var sizeItems: [(label: String, value: String)] {
        [
            ("SHOES", user.shoe_size ?? ""),
            ("RING",  user.ring_size ?? ""),
            ("JEANS", user.jeans_size ?? ""),
            ("DRESS", user.dress_size ?? ""),
            ("TOP",   user.top_size ?? ""),
        ].filter { !$0.value.isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "ruler")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.covetGreen())
                Text("Sizes")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(sizeItems, id: \.label) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                            .tracking(0.5)
                        Text(item.value)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(14)
        .background(Color(UIColor.systemGray6).opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(UIColor.systemGray5), lineWidth: 1))
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

private struct FollowersFollowingListView: View {
    let title: String
    let users: [CovetUser]

    var body: some View {
        List(users) { user in
            UserListItem(user: user, showRelationshipToUser: true, showPendingOptions: false)
                .listRowInsets(EdgeInsets())
        }
        .listStyle(.plain)
        .navigationBarTitle(title, displayMode: .inline)
    }
}

struct UserProfileNoPostsYet : View {
    var isOwnProfile: Bool
    var body : some View {
        VStack(spacing: 12) {
            Spacer()
            Text("No posts yet.")
                .font(.headline)
            if isOwnProfile {
                Group {
                    Text("Add something with the ").foregroundColor(.secondary) +
                    Text("covet").foregroundColor(Color.covetGreen()) +
                    Text(". button in Safari").foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            }
            Spacer()
        }
        .frame(minHeight: 200)
    }
}

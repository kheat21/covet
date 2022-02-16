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
        VStack {
            // Show the number of people they're connected to
            if let follows = user.follows, let followers = user.followers, let friends = user.friends {
                UserRelationshipsHero(
                    following: follows,
                    followers: followers,
                    friends: friends
                )
                .zIndex(2)
            } else {
                if user.follows_count != nil && user.followers_count != nil && user.friends_count != nil {
                    UserRelationshipsHero(
                        following_count: user.follows_count!,
                        followers_count: user.followers_count!,
                        friends_count: user.friends_count!
                    )
                    .zIndex(2)
                }
            }
                        
            // Show their posts
            if let posts = user.posts {
                if posts.count == 0 {
                    UserProfileNoPostsYet(isOwnProfile: self.isOwnProfile())
                } else {
                            
                    // Show the most recent one
                    CovetSquareZoomedInItem(
                        url: posts[0].products![0].image_url,
                        size: AppConfig.getCovetImageWidth(),
                        topBorderWidth: 8,
                        leftBorderWidth: 8,
                        bottomBorderWidth: 8,
                        rightBorderWidth: 8
                    )
                    .zIndex(1)
                    .frame(
                        width: AppConfig.getCovetImageWidth(),
                        height: AppConfig.getCovetImageWidth(),
                        alignment: .top
                    )
                    .onTapGesture {
                        self.showPostInDetailView = posts.first!
                    }
                    
                    // Space them out so that the scroll view doesn't
                    // get pushed too low or too high
                    Spacer()
                                          
                    // Show all the others
                    ScrollView {
                        ImageGrid(images: posts.suffix(posts.count - 1)) { i in
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

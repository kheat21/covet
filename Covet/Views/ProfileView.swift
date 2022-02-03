//
//  ProfileView.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI
import Firebase

struct ProfileView: View {

    @EnvironmentObject var auth: AuthService
    
    @State var isLoggedInUser: Bool;
    @State var userId: Int? = -1
    @State var isLoading: Bool = false
    @State var otherUser: CovetUser? = nil
    
    @State var showFriendView: Bool = false
    @State var showPostInDetailView: Post? = nil
    @State var showManagerView: Bool = false

    var body: some View {
        NavigationView {            
            VStack {
                NavigationLink(isActive: self.$showManagerView, destination: {
                    if let user = self.getUser() {
                        HamburgerOptionsView(user: user)
                    }
                }, label: {
                    EmptyView()
                })
                if let user = getUser() {
                        
                        // Show the number of people they're connected to
                        if let follows = user.follows, let followers = user.followers, let friends = user.friends {
                            UserRelationshipsHero(
                                following: follows,
                                followers: followers,
                                friends: friends,
                                pending: user.pending_incoming
                            )
                        }
                        
                        // Show their posts
                        if let posts = user.posts {
                            if posts.count == 0 {
                                Spacer()
                                Text("No posts yet. Add something with the Covet button in Safari to make one!")
                                    .padding([.leading, .trailing], 64)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            } else {
                                
                                // Show the most recent one
                                CovetSquareZoomedInItem(
                                    url: posts[0].products![0].image_url,
                                    size: 250,
                                    topBorderWidth: 8,
                                    leftBorderWidth: 8,
                                    bottomBorderWidth: 8,
                                    rightBorderWidth: 8
                                )
                                .background(Color.brown)
                                .frame(width: 250, height: 250, alignment: .top)
                                
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
                } else {
                    if self.isLoading {
                        ProgressView()
                    } else {
                        Text("Error loading user. Please try again later.")
                    }
                }
            }
            .navigationBarHidden(getCurrentUserHandle() == nil)
            .navigationBarTitle(getCurrentUserHandle() ?? "Loading...")
            .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
            .navigationBarItems(
                trailing: Button(
                    action: {
                        self.showManagerView = true
                    }
                )
                {
                    Image(systemName: "line.horizontal.3")
                }
            )
        }
        .sheet(item: self.$showPostInDetailView, onDismiss: {
            self.showPostInDetailView = nil
        }, content: { p in
            PostView(post: p)
        })
        .onAppear {
            print("ON APPEAR")
            Task {
                print("Is logged in user?")
                print(self.isLoggedInUser)
                if !self.isLoggedInUser && self.otherUser == nil {
                    self.isLoading = true
                    do {
                        print("Getting that user...")
                        if let resp = try await API.getUser(user_id: self.userId!) {
                            print(resp)
                            self.otherUser = resp.user
                        }
                        print("______ POSTS ______")
                        print(self.otherUser?.posts)
                    } catch {
                        print("Error getting the user")
                    }
                    self.isLoading = false
                }
            }
        }
    }
    
    func getUser() -> CovetUser? {
        return isLoggedInUser ? auth.currentCovetUser : self.otherUser
    }
    
    func getCurrentUserHandle() -> String? {
        if let user = self.getUser() {
            return user.username
        }
        return nil
    }
    
}

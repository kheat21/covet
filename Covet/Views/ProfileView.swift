//
//  ProfileView.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI
import Firebase

struct ProfileView: View {
    
//    var shouldShowSavingToast: Binding<Bool>
//    var shouldShowErrorToast: Binding<Bool>
//    var errorToastContents: Binding<String>
    
    @EnvironmentObject var auth: AuthService
    
    var isLoggedInUser: Bool;
    private var userId: Int? = -1

    @State var isLoading: Bool = false
    @State var otherUser: CovetUser? = nil
    
    init(
//        shouldShowSavingToast: Binding<Bool>,
//        shouldShowErrorToast: Binding<Bool>,
//        errorToastContents: Binding<String>
    ) {
        self.userId = nil
        self.isLoggedInUser = true
//
//        self.shouldShowSavingToast = shouldShowSavingToast
//        self.shouldShowErrorToast = shouldShowErrorToast
//        self.errorToastContents = errorToastContents
    }
    
    init(
        id: Int //,
//        shouldShowSavingToast: Binding<Bool>,
//        shouldShowErrorToast: Binding<Bool>,
//        errorToastContents: Binding<String>
    ) {
        self.userId = id
        self.isLoggedInUser = false
        
//        self.shouldShowSavingToast = shouldShowSavingToast
//        self.shouldShowErrorToast = shouldShowErrorToast
//        self.errorToastContents = errorToastContents
    }
    
    @State var showFriendView: Bool = false
    
    @State var showPostInDetailView: Post? = nil
    
    @State var showManagerView: Bool = false
    
    @Sendable
    func onAppear() async {
        if !self.isLoggedInUser {
            do {
                self.isLoading = true
                if let resp = try await API.getUser(user_id: self.userId!) {
                    return self.otherUser = resp.user
                }
                print("______ POSTS ______")
                print(self.otherUser?.posts)
            } catch {
                print("Error getting the user")
            }
        }
    }

    var body: some View {
        NavigationView {            
            VStack {
                NavigationLink(isActive: self.$showManagerView, destination: {
                    if let user = self.getUser() {
                        HamburgerOptionsView(
                            user: user //,
//                            shouldShowSavingToast: self.shouldShowSavingToast,
//                            shouldShowErrorToast: self.shouldShowErrorToast,
//                            errorToastContents: self.errorToastContents
                        )
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
                                pending: user.pending //,
//                                shouldShowSavingToast: self.shouldShowSavingToast,
//                                shouldShowErrorToast: self.shouldShowErrorToast,
//                                errorToastContents: self.errorToastContents
                            )
                        }
                        
                        // Show their posts
                        if let posts = user.posts {
                            if posts.count == 0 {
                                Spacer()
                                Text("No posts yet. Add something with the Covet button to make one!")
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
//        .sheet(isPresented: self.$showManagerView, onDismiss: nil, content: {
//            HamburgerOptionsView()
//            UserSettingsView(
//                mode: UserSettingsViewPresentationOptions.Modify,
//                handle: getCurrentUserHandle() ?? "",
//                name: self._user?.name ?? "",
//                birthday: self._user?.birthday ?? Date(),
//                privateForFollowing: self._user?.privateForFollowing == 1,
//                privateForFriending: self._user?.privateForFriending == 1
//            )
//        })
        .task(self.onAppear)
    }
    
    func getUser() -> CovetUser? {
        return isLoggedInUser
            ? auth.currentCovetUser
            : self.otherUser
    }
    
    func getApplicableUser() async throws -> CovetUser? {
        if self.isLoggedInUser {
            return try await auth.currentCovetUser
        } else {
            if let resp = try await API.getUser(user_id: self.userId!) {
                return resp.user
            }
        }
        return nil
    }
    
    func getCurrentUserHandle() -> String? {
        if let user = self.getUser() {
            return user.username
        }
        return nil
    }
    
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(isNa)
//    }
//}


//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Text(getCurrentUserHandle() ?? "No handle")
//                        .font(Font.title)
//                        .fontWeight(Font.Weight.bold)
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        do {
//                            try Auth.auth().signOut()
//                        } catch {}
//                    }) {
//                        Image(systemName: "ellipsis")
//                            .foregroundColor(Color.green)
//                    }
//                }
//            }

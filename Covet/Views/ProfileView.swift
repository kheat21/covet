//
//  ProfileView.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI
import Firebase

struct ProfileView: View {
    
    @State var _user: CovetUser? = nil
    
    @State var showFriendView: Bool = false
    
    @State var showPostInDetailView: Post? = nil
    
    @State var isNavigationBarHidden: Bool = true
    
    @Sendable
    func onAppear() async {
        do {
            self._user = try await AuthService.shared.getUser()
            print("______ POSTS ______")
            print(self._user?.posts)
        } catch {
            print("Error getting the user")
        }
    }

    var body: some View {
       
        VStack {
            if let user = _user {
                    
                    // Show the number of people they're connected to
                    if let follows = user.follows,
                        let followers = user.followers,
                            let friends = user.friends {
                        UserRelationshipsHero(following: follows, followers: followers, friends: friends)
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
                                ImageGrid(images: posts.suffix(posts.count - 1).map { $0
                                    return $0.products![0].image_url
                                }) { i in
                                    self.showPostInDetailView = self._user!.posts![i]
                                }
                            }
                        }
                    }
            } else {
                Text("Error loading user. Please try again later.")
            }
        }
        .sheet(item: self.$showPostInDetailView, onDismiss: {
            self.showPostInDetailView = nil
        }, content: { p in
            PostView(post: p)
        })
        .task(self.onAppear)
    }
    
//    func getCurrentUserHandle() -> String? {
//        if let user = self.$user.wrappedValue {
//            return user.username
//        }
//        return nil
//    }
    
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

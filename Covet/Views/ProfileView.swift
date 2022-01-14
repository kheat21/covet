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
    
    @Sendable
    func onAppear() async {
        do {
            self._user = try await AuthService.shared.getUser()
        } catch {
            print("Error getting the user")
        }
    }
    
    let items = [
        "https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Temple_T_logo.svg/905px-Temple_T_logo.svg.png",
        "https://cdn.shopify.com/s/files/1/0050/0182/products/AGingersSoul_3Q_1000x_70459821-7f81-4bd3-a36d-a2b853c430f0.jpg?v=1622118317",
        "https://www.thespruce.com/thmb/5ZpyukLcBAS448-r2P43k9wDmEs=/3360x2240/filters:fill(auto,1)/signs-to-replace-your-couch-4165258-hero-5266fa7b788c41f6a02f24224a5de29b.jpg",
        "https://i.insider.com/5a4f6ba3c32ae634008b49f0?width=800&format=jpeg",
        "https://www.womansworld.com/wp-content/uploads/sites/2/2018/05/tjmaxx-handbags.jpg",
        "https://images.squarespace-cdn.com/content/v1/5c479b7f710699200cbe95de/1553910021271-2PJYW4J4THGDNDUECDGD/TjMaxx-Interior%28web%2913.jpg",
        "https://www.bostonherald.com/wp-content/uploads/migration/2016/05/04/050416maxnl05.jpg"
    ];
    
    private var gridItems = [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]

    var body: some View {
        ZStack {
            if let user = _user {
                VStack {
                    
                    // Show the number of people they're connected to
                    if let follows = user.follows, let followers = user.followers, let friends = user.friends {
                        UserRelationshipsHero(following: follows, followers: followers, friends: friends)
                    }
                    
                    // Show their posts
                    if let posts = user.posts {
                        
                        // Show the most recent one
                        CovetSquareZoomedInItem(
                            url: items[0],
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
                            ImageGrid(images: posts.map { $0
                                return $0.products[0].image_url
                            })
                        }
                    }
                    
                }
                //.navigationBarTitle("Profile")
                .navigationBarHidden(false)
                //.navigationBarItems(leading: backButton, trailing: addButton)
                
            } else {
                Text("Error loading user. Please try again later.")
            }
        }.task(self.onAppear)
        
    }
    
//    func getCurrentUserHandle() -> String? {
//        if let user = self.$user.wrappedValue {
//            return user.username
//        }
//        return nil
//    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}


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

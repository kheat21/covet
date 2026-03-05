//
//  Covet.swift
//  Covet
//
//  Created by Brendan Manning on 1/1/22.
//SearchView.swift

import SwiftUI

struct CovetView : View {
    
    @EnvironmentObject var auth: AuthService;
    @State var showCreatePostView = false
    
//    @State private var shouldShowSavingToast: Bool = false
//    @State var shouldShowErrorToast: Bool = false
//    @State var errorToastContents: String = ""
    
    var body : some View {
        TabView {
            NavigationView {
                FeedView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Image("Covet_Logo_BW")
                                .resizable()
                                .scaledToFit()
                                .frame(width: nil, height: 20, alignment: Alignment.center)
                        }
                    }
            }
            .tabItem {
                Label("Feed", systemImage: "list.dash")
                    .foregroundColor(Color.covetGreen())
            }
            .tag(0)
            
            SearchView(
//                shouldShowSavingToast: $shouldShowSavingToast,
//                shouldShowErrorToast: $shouldShowErrorToast,
//                errorToastContents: $errorToastContents
            )
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                        .foregroundColor(Color.covetGreen())
                }
                .tag(1)
            
            if shouldShowBadge(currentCovetUser: auth.currentCovetUser) {
                ProfileView(isMe: true)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                        .foregroundColor(Color.covetGreen())
                }
                .tag(2)
                .badge(badgeContents(currentCovetUser: auth.currentCovetUser))
            } else {
                ProfileView(isMe: true)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                        .foregroundColor(Color.covetGreen())
                }
                .tag(2)
            }
        }
        .font(.headline)
        .accentColor(.covetGreen())
        .popover(isPresented: self.$showCreatePostView, content: {
            CreatePostView()
        })
    }
}

func shouldShowBadge(currentCovetUser: CovetUser?) -> Bool {
    guard let usr = currentCovetUser else { return false }
    return usr.countPendingIncoming() > 0
}

func badgeContents(currentCovetUser: CovetUser?) -> Int {
    return currentCovetUser!.countPendingIncoming()
}

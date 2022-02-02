//
//  Covet.swift
//  Covet
//
//  Created by Brendan Manning on 1/1/22.
//

import SwiftUI

struct CovetView : View {

    @State var showCreatePostView = false
    
//    @State private var shouldShowSavingToast: Bool = false
//    @State var shouldShowErrorToast: Bool = false
//    @State var errorToastContents: String = ""
    
    var body : some View {
        TabView {
            NavigationView {
                
                FeedView()
                    .navigationBarItems(
                        trailing: Button(
                            action: {
                                self.showCreatePostView = true
                            }
                        )
                        {
                            Image(systemName: "plus")
                        }
                    )
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
            
            //NavigationView {
                ProfileView(
//                    shouldShowSavingToast: $shouldShowSavingToast,
//                    shouldShowErrorToast: $shouldShowErrorToast,
//                    errorToastContents: $errorToastContents
                )
//                .navigationBarHidden(false)
//                .navigationBarTitle("My Profile")
//                .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
//            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
                    .foregroundColor(Color.covetGreen())
            }
            .tag(2)
            
        }
        .font(.headline)
        .accentColor(.covetGreen())
        .popover(isPresented: self.$showCreatePostView, content: {
            CreatePostView()
        })
    }
}

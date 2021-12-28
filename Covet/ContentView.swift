//
//  ContentView.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    @State var amplifyConfigured = false
    @State var userLoggedIn = false
    
    @State var showCreatePostView = false

    var body: some View {

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
                    .foregroundColor(Color.green)
            }
            .tag(0)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                        .foregroundColor(Color.green)
                }
                .tag(1)
                    
            
            ProfileView()
            .tabItem {
                Label("Profile", systemImage: "person.fill")
                    .foregroundColor(Color.green)
            }
            .tag(2)
            
        }
        .font(.headline)
        .accentColor(.green)
        .popover(isPresented: self.$showCreatePostView, content: {
            CreatePostView()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

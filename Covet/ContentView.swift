//
//  ContentView.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            
            TabView {
                FeedView()
                    .tabItem {
                        Label("Feed", systemImage: "list.dash")
                    }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            }.toolbar {
                ToolbarItem(placement: .principal) {
                    Image("Covet_Logo_BW")
                        .resizable()
                        .scaledToFit()
                        .frame(width: nil, height: 20, alignment: Alignment.center)
                }
            }
        }
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

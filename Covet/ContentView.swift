//
//  ContentView.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI

import Amplify
import AWSDataStorePlugin
import AWSCognitoAuthPlugin

struct ContentView: View {
    
    @State var amplifyConfigured = false
    @State var userLoggedIn = false
    
    @ObservedObject var amplifyService: AmplifyService;
    @ObservedObject var authService: AuthService;
    
    var body: some View {
        if !self.$amplifyService.isConfigured.wrappedValue {
            NavigationView {
                Text("Configuring Amplify...")
            }
        }
        else if !self.$authService.isLoggedIn.wrappedValue {
            NavigationView {
                VStack {
                    Text("Need to log in")
                    Button("Login", action: {
                        AuthService.shared.socialSignInWithWebUI()
                    })
                }
            }
        }
        else {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(amplifyService: AmplifyService.shared, authService: AuthService.shared)
    }
}

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
            AuthenticationView()
        }
        else {
           
                TabView {
                    NavigationView {
                        FeedView()
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
                    
                    NavigationView {
                        ProfileView()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Text("brendanmanning")
                                        .font(Font.title)
                                        .fontWeight(Font.Weight.bold)
                                }
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        AuthService.shared.signOut()
                                    }) {
                                        Image(systemName: "ellipsis")
                                            .foregroundColor(Color.green)
                                    }
                                }
                            }
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                            .foregroundColor(Color.green)
                    }
                    .tag(1)
                }
                .font(.headline)
                .accentColor(.green)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            amplifyService: AmplifyService.mocked,
            authService: AuthService.mockedLoggedIn
        )
    }
}

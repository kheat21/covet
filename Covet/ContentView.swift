//
//  ContentView.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    @State var userAccountExistenceChecked = false
    @State var userAccountCreated = false
    
    @State var amplifyConfigured = false
    @State var userLoggedIn = false
    
    var body: some View {
        if userAccountExistenceChecked {
            if userAccountCreated {
                CovetView()
            }
            else {
                UserSettingsView(
                    mode: UserSettingsViewPresentationOptions.NewSignup,
                    handle: "",
                    name: "",
                    birthday: Date(),
                    privateForFollowing: false,
                    privateForFriending: false,
                    userCreatedCallback: { profile in
                        AuthService.shared.rememberThatAProfileWasCreated(user: profile)
                        self.userAccountCreated = true
                    }
                )
            }
        } else {
            VStack {
                CovetC(size: 128)
                Text("Covet")
            }
            .task {
                do {
                    let profileExists = try await AuthService.shared.profileExistsForCurrentUser()
                    userAccountExistenceChecked = true
                    userAccountCreated = profileExists
                } catch {
                    fatalError("Unable to verify whether account exists or not")
                }
                /*
                if let user = Auth.auth().currentUser {
                    if AuthService.shared.wasAProfileProbablyAlreadyCreatedFor(authId: user.uid) {
                        
                        // Set these to true for now ...
                        userAccountExistenceChecked = true
                        userAccountCreated = true
                        
                        // But just in case, go and verify with the server...
                        do {
                            let profileExists = try await AuthService.shared.profileExistsForCurrentUser()
                            if !profileExists {
                                userAccountCreated = true
                            }
                        } catch {
                            userAccountExistenceChecked = false
                            userAccountCreated = false
                        }
                    } else {
                        userAccountExistenceChecked = true
                        userAccountCreated = false
                        // Check on the network
                    }
                }
                 */
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

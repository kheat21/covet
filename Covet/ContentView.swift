//
//  ContentView.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import AlertToast
import SwiftUI
import Firebase

struct ContentView: View {
    
    @EnvironmentObject var auth: AuthService
    @EnvironmentObject var settings: LocalSettingsService
    
    @State var userAccountExistenceChecked = false
    @State var userAccountCreated = false
    
    @State var amplifyConfigured = false
    @State var userLoggedIn = false
    
//    var shouldShowUserLoadingToast = Binding(
//        get: { auth.gettingCurrentCovetUser && settings.showNotificationWhenRefreshingUser },
//        set: { newValue in {} }
//    )
    
    var body: some View {
        ZStack {
        if !auth.gettingCurrentCovetUserFirstTime {
            if auth.currentCovetUserExists == true {
                if auth.currentCovetUserDeleted == true {
                    VStack {
                        Spacer()
                        Text("User Deleted")
                            .multilineTextAlignment(.center)
                        Spacer().frame(height: 16)
                        Button("Logout", action: {
                            auth.logout()
                        })
                        Spacer()
                    }
                } else {
                    CovetView()
                }
            }
            else {
                NavigationView {
                    UserSettingsView(
                        mode: UserSettingsViewPresentationOptions.NewSignup,
                        handle: "",
                        name: "",
                        birthday: Date(),
                        privateForFollowing: false,
                        privateForFriending: false,
                        userCreatedCallback: { profile in
                            // auth.rememberThatAProfileWasCreated(user: profile)
                            self.userAccountCreated = true
                        }
                    )
                }
            }
        } else {
            VStack {
                Image("Covet_Logo_Colored")
                    .frame(width: nil, height: 192)
            }
            .task {
                do {
//                    let profileExists = try await auth.profileExistsForCurrentUser()
//                    userAccountExistenceChecked = true
//                    userAccountCreated = profileExists
                    await auth.refreshUser()
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
        .toast(isPresenting: $auth.gettingCurrentCovetUser && $settings.showNotificationWhenRefreshingUser, alert: {
            AlertToast(displayMode: .hud, type: .loading, title: "Refreshing User")
        })
        .toast(isPresenting: $auth.errorGettingCurrentCovetUser && $settings.showErrorWhenUserRefreshFails, alert: {
            AlertToast(displayMode: .hud, type: .error(Color.red), title: "Error Refreshing")
        })
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  CovetApp.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI

import Firebase

@main
struct CovetApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    /*
    
    @State var amplifyConfigured = false
    @State var checkingForLogin = false
    @State var userLoggedIn = false
    
    func configureAmplify() {
        let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
        let authenticationPlugin = AWSCognitoAuthPlugin()
        do {
            try Amplify.add(plugin: dataStorePlugin)
            try Amplify.add(plugin: authenticationPlugin)
            try Amplify.configure()
            print("Initialized Amplify");
            amplifyConfigured = true;
        } catch {
            // simplified error handling for the tutorial
            print("Could not initialize Amplify: \(error)")
        }
    }
    
    func fetchCurrentAuthSession() {
        _ = Amplify.Auth.fetchAuthSession { result in
            switch result {
            case .success(let session):
                print("Is user signed in - \(session.isSignedIn)")
                userLoggedIn = true
            case .failure(let error):
                print("Fetch session failed with error \(error)")
                userLoggedIn = false
            }
        }
    }
    
//    public init() {
//        configureAmplify()
//        fetchCurrentAuthSession()
//    }
     
    */
    
    public init() {
        FirebaseApp.configure()
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(amplifyService: AmplifyService.shared, authService: AuthService.shared)
        }
    }
    
   /* func getBody() -> Scene {
        if(!_amplifyConfigured.wrappedValue) {
            return WindowGroup {
                Text("Configuring Amplify...")
            }
        }
        if(!_userLoggedIn.wrappedValue) {
            return WindowGroup {
                Text("Must log in")
            }
        }
        return WindowGroup {
            ContentView()
        }
    } */
}

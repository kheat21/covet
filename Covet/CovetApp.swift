//
//  CovetApp.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI

import Firebase
import FirebaseUI

@main
struct CovetApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    public init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Text("Covet App")
            /*
             //ContentView(amplifyService: AmplifyService.shared, authService: AuthService.shared)
            if AuthService.shared.isLoggedIn {
                ContentView(amplifyService: AmplifyService.shared, authService: AuthService.shared)
            } else {
                LoginView()
            }*/
        }
    }
    
}

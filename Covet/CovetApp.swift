//
//  CovetApp.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import AlertToast
import Combine
import SwiftUI
import Firebase
import FirebaseAuthUI

@main
struct CovetApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @ObservedObject var auth: AuthService = AuthService()
    @ObservedObject var settings: LocalSettingsService = LocalSettingsService()
    
    public init() {
        FirebaseApp.configure()
        auth.initialize()
    }
    
    var body: some Scene {
        
        WindowGroup {
            if auth.isLoggedIn {
                ContentView()
                    .environmentObject(auth)
                    .environmentObject(settings)
                    .onAppear {
                        UserHelpNudgeKeys.setup()
                    }
            } else {
                LoginView()
                    .environmentObject(auth)
                    .environmentObject(settings)
            }
        }
    }
    
}

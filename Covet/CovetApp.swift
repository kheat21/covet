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
    @StateObject var deepLinkRouter: DeepLinkRouter = DeepLinkRouter()
    
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
                    .environmentObject(deepLinkRouter)
                    .onAppear {
                        UserHelpNudgeKeys.setup()
                    }
                    .onOpenURL { url in deepLinkRouter.handle(url: url) }
            } else {
                LoginView()
                    .environmentObject(auth)
                    .environmentObject(settings)
                    .onOpenURL { url in deepLinkRouter.handle(url: url) }
            }
        }
    }
    
}

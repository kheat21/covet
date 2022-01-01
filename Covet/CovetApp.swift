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

    @ObservedObject var auth: AuthService = AuthService.shared
    
    public init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if auth.isLoggedIn {
                ContentView()
            } else {
                LoginView()
            }
                
        }
        
    }
    
    
}

//
//  SceneDelegate.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Foundation
import UIKit
import FirebaseAuth
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
                
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            if Auth.auth().currentUser == nil {
                window.rootViewController = UIHostingController(rootView: LoginView())
            }
            else {
                window.rootViewController = UIHostingController(rootView:ContentView())
            }
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

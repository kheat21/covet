//
//  AppDelegae.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Foundation
import UIKit

import Amplify
import AWSCognitoAuthPlugin

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        do {
//            try Amplify.add(plugin: AWSCognitoAuthPlugin())
//            try Amplify.configure()
//            print("Amplify configured with auth plugin")
//        } catch {
//            print("Failed to initialize Amplify with \(error)")
//        }
        
        return true
    }
}

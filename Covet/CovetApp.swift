//
//  CovetApp.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI

import Amplify
import AWSDataStorePlugin

@main
struct CovetApp: App {
    
    func configureAmplify() {
        let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
        do {
            try Amplify.add(plugin: dataStorePlugin)
            try Amplify.configure()
            print("Initialized Amplify");
        } catch {
            // simplified error handling for the tutorial
            print("Could not initialize Amplify: \(error)")
        }
    }
    
    public init() {
        configureAmplify()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//
//  AmplifyService.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Foundation


class AmplifyService: NSObject, ObservableObject {
    
    @Published var isConfigured: Bool = false;
    
    init(defaultIsConfiguredValue: Bool = false) {
        self.isConfigured = defaultIsConfiguredValue;
    }
    
    static let shared = AmplifyService()
    static let mocked = AmplifyService(defaultIsConfiguredValue: true)
    
    func configureAmplify() {
//        let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
//        let authenticationPlugin = AWSCognitoAuthPlugin()
        do {
//            try Amplify.add(plugin: dataStorePlugin)
//            try Amplify.add(plugin: authenticationPlugin)
//            try Amplify.configure()
//            print("Initialized Amplify");
            self.isConfigured = true;
            AuthService.shared.listen()
        } catch {
            // simplified error handling for the tutorial
            print("Could not initialize Amplify: \(error)")
        }
    }
}

//
//  AuthService.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Foundation
import Combine
import UIKit

import Firebase
import FirebaseAuth

class AuthService: NSObject, ObservableObject {
    
    @Published var isLoggedIn: Bool = false;
    @Published var currentCovetUser: CovetUser? = nil;
    
    static let shared = AuthService()
    
    func initialize() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            self.isLoggedIn = auth.currentUser != nil
        }
    }
    
    func rememberThatAProfileWasCreated(user: CovetUser) {
        UserDefaults.standard.set(user.authId, forKey: "auth_service_recall_profile_created_for")
    }
    
    func wasAProfileProbablyAlreadyCreatedFor(authId: String) -> Bool {
        return true
        if let recalled_user = UserDefaults.standard.string(forKey: "auth_service_recall_profile_created_for") {
            return recalled_user == authId
        }
        return false
    }
    

    func setLoggedIn() {
        //self.isLoggedIn = true
    }
    
    func setLoggedOut() {
        //self.isLoggedIn = false
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            //self.isLoggedIn = false
        } catch {}
    }
    
    func getUser() async throws -> CovetUser? {
        
        // If we have a cached copy of the currentCovetUser
        // object, then there is no need to sync with Firebase
        guard self.currentCovetUser == nil else {
            print(self.currentCovetUser!)
            return self.currentCovetUser
        }
        
        // Otherwise, we have to get the profile from the server
        self.currentCovetUser = try await API.me()
        
        // Regardless, return whatever it is that we have
        return self.currentCovetUser
        
    }
    
}

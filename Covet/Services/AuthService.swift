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
        print("Setting up Auth state listener")
        Auth.auth().addStateDidChangeListener { (auth, user) in
            print("Got a callback on the auth state")
            self.isLoggedIn = auth.currentUser != nil
            Task {
                print("In the Task")
                if !self.isLoggedIn {
                    print("Clearning ID token from UserDefaults")
                    UserDefaults.standard.removeObject(forKey: "id_token")
                    
                    print("Clearing ExtensionTokenService...")
                    ExtensionTokenStateManagement.clear()
                }
            }
        }
    }
    
    func rememberThatAProfileWasCreated(user: CovetUser) {
        UserDefaults.standard.set(user.authId, forKey: "auth_service_recall_profile_created_for")
    }
    
    func wasAProfileProbablyAlreadyCreatedFor(authId: String) -> Bool {
        if let recalled_user = UserDefaults.standard.string(forKey: "auth_service_recall_profile_created_for") {
            print("Comparing " + recalled_user + " and authId=" + authId)
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
    
    func profileExistsForCurrentUser() async throws -> Bool {
        print("Does profile exist for current user?")
        let answer = try await getUser() != nil
        print("Answer was " + String(answer))
        return answer
    }
    
    func getUser() async throws -> CovetUser? {
        
        // If we have a cached copy of the currentCovetUser
        // object, then there is no need to sync with Firebase
        guard self.currentCovetUser == nil else {
            print("The current user is not nil")
            print(self.currentCovetUser!)
            return self.currentCovetUser
        }
        
        // Otherwise, we have to get the profile from the server
        print("Trying to get the current user from the server...")
        if let meresp = try await API.me() {
            if let me = meresp.user {
             
                self.currentCovetUser = meresp.user
                print("Got this user")
                print(self.currentCovetUser)
                
                // Updating the extension token now that the user
                // account is guarenteed to be made
                let token = await API.getIdToken()
                print("Trying to save the ID token (" + token! + ") in UserDefaults...")
                UserDefaults.standard.set(token, forKey: "id_token")
                
                print("Updating ExtensionTokenService...")
                await ExtensionTokenStateManagement.update(uid: self.currentCovetUser!.authId)
                
            }
        }
        
        // Regardless, return whatever it is that we have
        return self.currentCovetUser
        
    }
    
    func markForRefresh() {
        self.currentCovetUser = nil
    }
    
}

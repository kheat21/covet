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
    @Published var gettingCurrentCovetUserFirstTime: Bool = false;
    @Published var gettingCurrentCovetUser: Bool = false;
    @Published var currentCovetUser: CovetUser? = nil;
    @Published var currentCovetUserExists: Bool? = nil;
    @Published var currentCovetUserDeleted: Bool? = nil
    @Published var errorGettingCurrentCovetUser: Bool = false;

    func initialize() {
        print("Setting up Auth state listener")
        Auth.auth().addStateDidChangeListener { (auth, user) in
            print("Got a callback on the auth state")
            self.isLoggedIn = auth.currentUser != nil
            
            
                print("In the Task")
                if self.isLoggedIn {
                    Task {
                        await self.firstFetch()
                        await self.refreshExtensionToken()
                    }
                
                }
            
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            self.currentCovetUser = nil
            self.clearExtensionToken()
        } catch {}
    }
    
    func firstFetch() async -> Void {
        self.gettingCurrentCovetUserFirstTime = true
        await self.refreshUser()
        self.gettingCurrentCovetUserFirstTime = false
    }
    
    func refreshUser() async -> Void {
        self.gettingCurrentCovetUser = true
        do {
            if let meresp = try await API.me() {
                if let me = meresp.user {
                    self.currentCovetUser = me
                    print(me)
                    self.currentCovetUserDeleted = (me.isDeleted == 1)
                }
                self.currentCovetUserExists = meresp.exists
            } else {
                self.errorGettingCurrentCovetUser = true
            }
        } catch {
            self.errorGettingCurrentCovetUser = true
        }
        self.gettingCurrentCovetUser = false
    }
    
    func refreshExtensionToken() async -> Bool {
        if let user = self.currentCovetUser {
            // Updating the extension token now that the user
            // account is guarenteed to be made
            let token = await API.getIdToken()
            print("Trying to save the ID token (" + token! + ") in UserDefaults...")
            UserDefaults.standard.set(token, forKey: "id_token")
            
            print("Updatcing ExtensionTokenService...")
            await ExtensionTokenStateManagement.update(uid: user.authId)
        }
        return false
    }
    
    func clearExtensionToken() -> Void {
        print("Clearning ID token from UserDefaults")
        UserDefaults.standard.removeObject(forKey: "id_token")
        
        print("Clearing ExtensionTokenService...")
        ExtensionTokenStateManagement.clear()
    }
    
}

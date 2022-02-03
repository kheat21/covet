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
                    
                    DispatchQueue.main.async {
                        self.firstFetch()
                        self.refreshExtensionToken()
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
    
    func firstFetch() -> Void {
        Task.detached {
            await self.setWorking(state: true, firstTime: true)
            self.refreshUser()
            await self.setWorking(state: false)
        }
    }
    
    func refreshUser() -> Void {
        Task.detached {
            
            await self.setWorking(state: true)
            
            var err: Bool = false
            var user: CovetUser? = nil
            var userDeleted: Bool? = nil
            var userExists: Bool? = nil
            
            do {
                if let meresp = try await API.me() {
                    if let me = meresp.user {
                        user = me
                        userDeleted = (me.isDeleted == 1)
                    
                    }
                    userExists = meresp.exists
                } else {
                    err = true
                }
            } catch {
                err = true
            }
            
            await self.updateUI(error: err, user: user, userExists: userExists, userDeleted: userDeleted)
            await self.setWorking(state: false)
        }
    }
    
    @MainActor
    func setWorking(state: Bool, firstTime: Bool = false) async {
        self.gettingCurrentCovetUser = state
        if firstTime {
            self.gettingCurrentCovetUserFirstTime = true
        } else {
            self.gettingCurrentCovetUserFirstTime = false
        }
    }
    
    @MainActor
    func updateUI(error: Bool, user: CovetUser?, userExists: Bool?, userDeleted: Bool?) async {
        self.errorGettingCurrentCovetUser = error
        if user != nil {
            self.currentCovetUser = user!
        }
        self.currentCovetUserExists = userExists
        self.currentCovetUserDeleted = userDeleted
    }
    
    func refreshExtensionToken() -> Void {
        Task.detached {
            if let user = self.currentCovetUser {
                // Updating the extension token now that the user
                // account is guarenteed to be made
                let token = await API.getIdToken()
                print("Trying to save the ID token (" + token! + ") in UserDefaults...")
                UserDefaults.standard.set(token, forKey: "id_token")
                
                print("Updatcing ExtensionTokenService...")
                await ExtensionTokenStateManagement.update(uid: user.authId)
            }
        }
    }
    
    func clearExtensionToken() -> Void {
        print("Clearning ID token from UserDefaults")
        UserDefaults.standard.removeObject(forKey: "id_token")
        
        print("Clearing ExtensionTokenService...")
        ExtensionTokenStateManagement.clear()
    }
    
}

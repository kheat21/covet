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

    @Published var isLoggedIn: Bool = false
    @Published var gettingCurrentCovetUserFirstTime: Bool = false
    @Published var gettingCurrentCovetUser: Bool = false
    @Published var currentCovetUser: CovetUser? = nil
    @Published var currentCovetUserExists: Bool? = nil
    @Published var currentCovetUserDeleted: Bool? = nil
    @Published var errorGettingCurrentCovetUser: Bool = false
    @Published var needsProfileSetup: Bool = false

    func initialize() {
        print("Setting up Auth state listener")

        // Firebase auth listener
        Auth.auth().addStateDidChangeListener { (auth, user) in
            print("Got a callback on the auth state")
            self.isLoggedIn = auth.currentUser != nil

            print("In the Task")
            if self.isLoggedIn {
                DispatchQueue.main.async {
                    self.firstFetch()
                }
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {}
        KeychainService.shared.clearAll()
        self.currentCovetUser = nil
        self.isLoggedIn = false
        self.clearExtensionToken()
        UserHelpNudgeKeys.resetAll()
    }

    func firstFetch() -> Void {
        Task.detached {
            self.refreshUser(first: true)
        }
    }

    func refreshUser(first: Bool = false) -> Void {
        Task.detached {

            await self.setWorking(state: true, firstTime: first)

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
            if first {
                self.refreshExtensionToken()
            }
        }
    }

    @MainActor
    func setWorking(state: Bool, firstTime: Bool = false) async {
        print("--> setWorking(state: " + String(state) + ", firstTime: " + String(firstTime))
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
            print("AuthService: Got the current user")
            self.currentCovetUser = user!
        } else {
            print("AuthService: New user - needs profile setup")
            self.needsProfileSetup = true
            self.gettingCurrentCovetUserFirstTime = false
        }
        self.currentCovetUserExists = userExists
        self.currentCovetUserDeleted = userDeleted
    }

    func refreshExtensionToken() -> Void {
        Task.detached {
            print("ExtensionTokenService: Beginning detatched refresh function")
            if let user = self.currentCovetUser {
                // Updating the extension token now that the user
                // account is guarenteed to be made
                let token = await API.getIdToken()
                print("ExtensionTokenService: Trying to save the ID token (" + token! + ") in UserDefaults...")
                UserDefaults.standard.set(token, forKey: "id_token")

                print("ExtensionTokenService: Updatcing ExtensionTokenService...")
                await ExtensionTokenStateManagement.update(uid: user.authId)
            } else {
                print("ExtensionTokenService: Could not update ExtensionTokenService because no user")
            }
        }
    }

    func clearExtensionToken() -> Void {
        print("Clearning ID token from UserDefaults")
        UserDefaults.standard.removeObject(forKey: "id_token")

        print("Clearing ExtensionTokenService...")
        ExtensionTokenStateManagement.clear()
    }

    // MARK: - Username Auth (not used, stubs for compilation)
    
    func loginWithUsername(_ username: String) async throws {
        throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Username auth not supported"])
    }

    func registerWithUsername(_ username: String, name: String) async throws {
        throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Username auth not supported"])
    }

}

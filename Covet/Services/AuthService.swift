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
    
    func rememberThatAProfileWasCreated(user: CovetUser) {
        UserDefaults.standard.set(user.authId, forKey: "auth_service_recall_profile_created_for")
    }
    
    func wasAProfileProbablyAlreadyCreatedFor(authId: String) -> Bool {
        if let recalled_user = UserDefaults.standard.string(forKey: "auth_service_recall_profile_created_for") {
            return recalled_user == authId
        }
        return false
    }
    

    func setLoggedIn() {
        self.isLoggedIn = true
    }
    
    func setLoggedOut() {
        self.isLoggedIn = false
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
        } catch {}
    }
    
    func getUser() async throws -> CovetUser? {
        
        // If we have a cached copy of the currentCovetUser
        // object, then there is no need to sync with Firebase
        guard self.currentCovetUser == nil else {
            print(self.currentCovetUser!)
            return self.currentCovetUser
        }
        
        /*
        
        // Otherwise, get the Firebase currentUser object
        // This will have the UID we need to resolve some
        // properties from the database
        if let currentUser = Auth.auth().currentUser {
            
            print("Fetching CovetUser for firebaseUID: " + currentUser.uid)
            
            // It is theoretically possible that multiple users will have the same firebase UID
            // This would be a catastrophic error, so we'll need to catch that here
            if let matching = await CovetUser.search(firebaseUID: currentUser.uid) {
                
                // If we find exactly one user (as we should), we'll cache
                // it for later use and then return it. (Using simple recursion)
                if matching.count == 1 {
                    self.currentCovetUser = matching[0]
                    return try await getUser()
                } else if matching.count > 1 {
                    throw RuntimeError("Multiple users found matching firebaseUID: " + currentUser.uid)
                }
            }
        } else {
            print("Unable to get CovetUser because Auth.auth().currentUser was nil")
        }
         
         
        */
        return nil
    }
    
}


//    init(mockedLoginState: Bool?, mockedUser: CovetUser? = nil) {
//        self._mockedLoginState = mockedLoginState;
//        self._mockedUser = mockedUser;
//        if(mockedLoginState != nil) {
//            isLoggedIn = mockedLoginState!;
//        }
//    }
//    static let mockedLoggedIn = AuthService(mockedLoginState: true, mockedUser: CovetUser.mockedSample1)
//    static let mockedLoggedOut = AuthService(mockedLoginState: false, mockedUser: nil)

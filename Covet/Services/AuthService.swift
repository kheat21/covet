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
    
    private var _mockedLoginState: Bool? = nil;
    private var _mockedUser: CovetUser? = nil;
    
    init(mockedLoginState: Bool?, mockedUser: CovetUser? = nil) {
        self._mockedLoginState = mockedLoginState;
        self._mockedUser = mockedUser;
        if(mockedLoginState != nil) {
            isLoggedIn = mockedLoginState!;
        }
    }
    
    static let shared = AuthService(mockedLoginState: nil, mockedUser: nil)
    static let mockedLoggedIn = AuthService(mockedLoginState: true, mockedUser: CovetUser.mockedSample1)
    static let mockedLoggedOut = AuthService(mockedLoginState: false, mockedUser: nil)
    
    private var window: UIWindow {
        guard
            let scene = UIApplication.shared.connectedScenes.first,
            let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
            let window = windowSceneDelegate.window as? UIWindow
        else { return UIWindow() }
        
        return window
    }

    
    func signIn() {
        //Auth.auth().signIn(with: <#T##AuthCredential#>, completion: <#T##((AuthDataResult?, Error?) -> Void)?##((AuthDataResult?, Error?) -> Void)?##(AuthDataResult?, Error?) -> Void#>)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func listen() {
        _ = Auth.auth().addStateDidChangeListener { auth, user in
            guard user != nil else {
                self.isLoggedIn = false
                return
            }
            self.isLoggedIn = true
        }
    }
    
    func getUser() -> CovetUser? {
        if self._mockedUser != nil {
            return self._mockedUser;
        } else if let currentUser = Auth.auth().currentUser {
            return CovetUser(
                uid: currentUser.uid
            )
        } else {
            return nil
        }
    }
    
}

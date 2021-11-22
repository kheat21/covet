//
//  AuthService.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Foundation
import Combine
import Amplify
import UIKit

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

    
    func socialSignInWithWebUI() {
        Amplify.Auth.signInWithWebUI(for: .google, presentationAnchor: window) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
                self.isLoggedIn = true;
            case .failure(let error):
                print("Sign in failed \(error)")
                self.isLoggedIn = false;
            }
        }
    }

    
    func listen() {
        _ = Amplify.Auth.fetchAuthSession { result in
            switch result {
                case .success(let session):
                    print("Is user signed in - \(session.isSignedIn)")
                    self.isLoggedIn = session.isSignedIn
                case .failure(let error):
                    print("Fetch session failed with error \(error)")
                    self.isLoggedIn = false
            }
        }
    }
    
    func getUser() -> CovetUser? {
        if self._mockedUser != nil {
            return self._mockedUser;
        } else if let currentAmplifyUser = Amplify.Auth.getCurrentUser() {
            return CovetUser(
                amplifyUserId: currentAmplifyUser.userId,
                username: currentAmplifyUser.username
            )
        } else {
            return nil
        }
    }
    
}

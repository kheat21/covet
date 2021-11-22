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
    
    static let shared = AuthService()
    
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
    
}

//
//  SigninViewController.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Foundation

import SwiftUI
import AWSMobileClientXCF

struct SignInViewController: UIViewControllerRepresentable {
    let navController =  UINavigationController()
    
    func makeUIViewController(context: Context) -> UINavigationController {
        navController.setNavigationBarHidden(true, animated: false)
        let viewController = UIViewController()
        navController.addChild(viewController)
        return navController
    }
    
    func updateUIViewController(_ pageViewController: UINavigationController, context: Context)   {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: SignInViewController
        
        init(_ signInViewController: SignInViewController) {
            self.parent = signInViewController
        }
    }
    
    
}

// MARK: Sign In With Google Extension
extension SignInViewController {
    func signInWithGoogle() {
        let hostedUIOptions = HostedUIOptions(scopes: ["openid", "email", "profile"], identityProvider: "Google")
        
        AWSMobileClient.default().showSignIn(navigationController: navController, hostedUIOptions: hostedUIOptions) { (userState, error) in
            if let error = error as? AWSMobileClientError {
                print(error.localizedDescription)
            }
            if let userState = userState {
                print("Status: \(userState.rawValue)")
                
                AWSMobileClient.default().getTokens { (tokens, error) in
                    if let error = error {
                        print("error \(error)")
                    } else if let tokens = tokens {
                        let claims = tokens.idToken?.claims
                        print("username? \(claims?["username"] as? String ?? "No username")")
                        print("cognito:username? \(claims?["cognito:username"] as? String ?? "No cognito:username")")
                        print("email? \(claims?["email"] as? String ?? "No email")")
                        print("name? \(claims?["name"] as? String ?? "No name")")
                        print("picture? \(claims?["picture"] as? String ?? "No picture")")
                    }
                }
            }
            
        }
    }
}

//
//  SimpleLoginView.swift
//  Covet
//
//  Simple username-based authentication
//

import SwiftUI

struct SimpleLoginView: View {
    
    @EnvironmentObject var auth: AuthService
    
    @State private var isSignUp: Bool = true
    @State private var username: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer().frame(height: 60)
            
            // Logo
            Image("Covet_Logo_Colored")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .padding(.bottom, 8)
            
            // Tagline
            Group {
                Text("Take the ")
                    .font(.system(.headline))
                    .foregroundColor(Color.gray)
                +
                Text("if")
                    .font(.system(.headline))
                    .foregroundColor(Color.covetGreen())
                +
                Text(" out of g")
                    .font(.system(.headline))
                    .foregroundColor(Color.gray)
                +
                Text("if")
                    .font(.system(.headline))
                    .foregroundColor(Color.covetGreen())
                +
                Text("t")
                    .font(.system(.headline))
                    .foregroundColor(Color.gray)
            }
            .padding(.bottom, 40)
            
            // Form
            VStack(spacing: 16) {
                
                // Title
                Text(isSignUp ? "Create Account" : "Welcome Back")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 8)
                
                // Username field
                VStack(alignment: .leading, spacing: 4) {
                    Text("Username")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("Enter username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                }
                
                // Name fields (only for signup)
                if isSignUp {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("First Name")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Enter first name", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last Name")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Enter last name", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                // Error message
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                // Submit button
                Button(action: submit) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    } else {
                        Text(isSignUp ? "Sign Up" : "Log In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                }
                .background(isFormValid ? Color.covetGreen() : Color.covetGreen().opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(!isFormValid || isLoading)
                .padding(.top, 8)
                
                // Toggle between signup and login
                Button(action: {
                    withAnimation {
                        isSignUp.toggle()
                        errorMessage = nil
                    }
                }) {
                    Text(isSignUp ? "Already have an account? Log In" : "Need an account? Sign Up")
                        .font(.subheadline)
                        .foregroundColor(Color.covetGreen())
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Footer links
            HStack(spacing: 20) {
                Button("Terms of Service") {
                    if let url = URL(string: AppConfig.TERMS_AND_CONDITIONS_LINK) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption)
                .foregroundColor(.gray)
                
                Button("Privacy Policy") {
                    if let url = URL(string: AppConfig.PRIVACY_POLICY_LINK) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding(.bottom, 32)
        }
    }
    
    private var isFormValid: Bool {
        let usernameValid = username.trimmingCharacters(in: .whitespaces).count >= 3
        if isSignUp {
            let firstNameValid = firstName.trimmingCharacters(in: .whitespaces).count >= 1
            let lastNameValid = lastName.trimmingCharacters(in: .whitespaces).count >= 1
            return usernameValid && firstNameValid && lastNameValid
        }
        return usernameValid
    }
    
    private func submit() {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if isSignUp {
                    // Register and create profile
                    let fullName = "\(firstName.trimmingCharacters(in: .whitespaces)) \(lastName.trimmingCharacters(in: .whitespaces))"
                    try await auth.registerWithUsername(username.trimmingCharacters(in: .whitespaces), name: fullName)
                } else {
                    // Just login
                    try await auth.loginWithUsername(username.trimmingCharacters(in: .whitespaces))
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

struct SimpleLoginView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleLoginView()
            .environmentObject(AuthService())
    }
}

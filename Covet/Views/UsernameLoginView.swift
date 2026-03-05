//
//  UsernameLoginView.swift
//  Covet
//

import SwiftUI

struct UsernameLoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var username = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Covet")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: login) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(username.count < 3 || isLoading)
            .padding(.horizontal)
            
            Text("Enter your username to login.\nNew users will be registered automatically.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Try login first
                try await authService.loginWithUsername(username)
            } catch {
                // If login fails, try register
                do {
                    try await authService.registerWithUsername(username)
                } catch {
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                    }
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

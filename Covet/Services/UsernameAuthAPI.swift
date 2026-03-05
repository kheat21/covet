//
//  UsernameAuthAPI.swift
//  Covet
//

import Foundation

struct AuthResponse: Codable {
    let success: Bool?
    let token: String?
    let userId: Int?
    let username: String?
    let error: String?
}

class UsernameAuthAPI {
    
    static func register(username: String) async throws -> AuthResponse {
        return try await authRequest(endpoint: "/user/register", username: username)
    }
    
    static func login(username: String) async throws -> AuthResponse {
        return try await authRequest(endpoint: "/user/login", username: username)
    }
    
    private static func authRequest(endpoint: String, username: String) async throws -> AuthResponse {
        let urlString = APIConfig.hostname + endpoint
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "InvalidURL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["username": username.lowercased().trimmingCharacters(in: .whitespaces)]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        return try decoder.decode(AuthResponse.self, from: data)
    }
}

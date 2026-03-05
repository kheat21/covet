//
//  KeychainService.swift
//  Covet
//

import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private let serviceName = "com.covet.auth"
    private let tokenKey = "jwt_token"
    private let userIdKey = "user_id"
    private let usernameKey = "username"
    
    func saveToken(_ token: String) -> Bool {
        return save(key: tokenKey, value: token)
    }
    
    func getToken() -> String? {
        return get(key: tokenKey)
    }
    
    func deleteToken() {
        delete(key: tokenKey)
    }
    
    func saveUserId(_ userId: Int) -> Bool {
        return save(key: userIdKey, value: String(userId))
    }
    
    func getUserId() -> Int? {
        guard let value = get(key: userIdKey) else { return nil }
        return Int(value)
    }
    
    func saveUsername(_ username: String) -> Bool {
        return save(key: usernameKey, value: username)
    }
    
    func getUsername() -> String? {
        return get(key: usernameKey)
    }
    
    func clearAll() {
        delete(key: tokenKey)
        delete(key: userIdKey)
        delete(key: usernameKey)
    }
    
    private func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        delete(key: key)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }
    
    private func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else { return nil }
        return value
    }
    
    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

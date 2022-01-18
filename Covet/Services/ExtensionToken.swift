//
//  ExtensionTokewn.swift
//  Covet
//
//  Created by Covet on 1/18/22.
//

import Foundation

struct ExtensionAuthenticationPackage {
    var uid: String;
    var local: String;
    var server: String;
}

class ExtensionTokenService {
    
    static func getTokens() -> ExtensionAuthenticationPackage? {
        if let uid = self.getCurrentUserUID(), let local = self.getLocalTokenComponent(), let server = self.getServerTokenComponent() {
            return ExtensionAuthenticationPackage(uid: uid, local: local, server: server)
        }
        return nil
    }
    
    static func update(uid: String) async -> Bool {
        do {
            let localTokenComponent = generateLocalToken()
            
            if let resp = try await ExtensionTokenService.setExtensionToken(localTokenComponent: localTokenComponent) {
                if let serverTokenComponent = resp.serverTokenComponent {
                    self.saveCurrentUserUID(str: uid)
                    self.saveServerTokenComponent(str: serverTokenComponent)
                    self.saveLocalTokenComponent(str: localTokenComponent)
                    return true
                }
            }
            
        } catch {}
        return false
    }
    
    static func clear() {
        UserDefaults.standard.removeObject(forKey: "CurrentUserUID")
        UserDefaults.standard.removeObject(forKey: "ServerTokenComponent")
        UserDefaults.standard.removeObject(forKey: "LocalTokenComponent")
    }
    
    private static func saveCurrentUserUID(str: String) {
        UserDefaults.standard.set(str, forKey: "CurrentUserUID")
    }

    private static func getCurrentUserUID() -> String? {
        UserDefaults.standard.string(forKey: "CurrentUserUID")
    }
    
    private static func saveServerTokenComponent(str: String) {
        UserDefaults.standard.set(str, forKey: "ServerTokenComponent")
    }

    private static func getServerTokenComponent() -> String? {
        UserDefaults.standard.string(forKey: "ServerTokenComponent")
    }
    
    private static func saveLocalTokenComponent(str: String) {
        UserDefaults.standard.set(str, forKey: "LocalTokenComponent")
    }
    
    private static func getLocalTokenComponent() -> String? {
        UserDefaults.standard.string(forKey: "LocalTokenComponent")
    }
    
    private static func generateLocalToken() -> String {
        return Strings.randomString(length: 128)
    }
    
    private static func setExtensionToken(localTokenComponent: String) async throws -> SetExtensionTokenResult? {
        return try await APIHelpers.getEndpointPromise(
            token: nil,
            endpoint: "/user/extension_token/set",
            method: .post,
            data: [
                "token": localTokenComponent
            ],
            SetExtensionTokenResult.self
        )
    }
}

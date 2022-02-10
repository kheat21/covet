//
//  ExtensionTokenStateManagement.swift
//  Covet
//
//  Created by Covet on 1/28/22.
//

import Foundation

class ExtensionTokenStateManagement {
    static func update(uid: String) async -> Bool {
        do {
            let localTokenComponent = generateLocalToken()
            
            if let resp = try await ExtensionTokenStateManagement.setExtensionToken(localTokenComponent: localTokenComponent) {
                print(resp)
                if let serverTokenComponent = resp.serverTokenComponent {
                    print("Saving user uid " + uid + "...")
                    self.saveCurrentUserUID(str: uid)
                    print("Saving server token " + serverTokenComponent + "...")
                    self.saveServerTokenComponent(str: serverTokenComponent)
                    print("Saving local token " + localTokenComponent + "...")
                    self.saveLocalTokenComponent(str: localTokenComponent)
                    return true
                } else {
                    print("Couldn't parse setExtensionToken response")
                }
            }
            
        } catch {
            print(error)
        }
        return false
    }
    
    static func clear() {
        Defaults.sharedSuite.removeObject(forKey: "CurrentUserUID")
        Defaults.sharedSuite.removeObject(forKey: "ServerTokenComponent")
        Defaults.sharedSuite.removeObject(forKey: "LocalTokenComponent")
    }
    
    private static func setExtensionToken(localTokenComponent: String) async throws -> SetExtensionTokenResult? {
        let tok =  await API.getIdToken()
        print("SENT THIS")
        print(tok)
        return try await APIHelpers.getEndpointPromise(
            token: tok,
            endpoint: "/user/extension_token/set",
            method: .post,
            data: [
                "token": localTokenComponent
            ],
            SetExtensionTokenResult.self,
            overrideBaseUrl: nil
        )
    }
    
    private static func generateLocalToken() -> String {
        return Strings.randomString(length: 128)
    }
    
    private static func saveLocalTokenComponent(str: String) {
        Defaults.sharedSuite.set(str, forKey: "LocalTokenComponent")
    }
    
    private static func saveServerTokenComponent(str: String) {
        Defaults.sharedSuite.set(str, forKey: "ServerTokenComponent")
    }
    
    private static func saveCurrentUserUID(str: String) {
        Defaults.sharedSuite.set(str, forKey: "CurrentUserUID")
    }
}

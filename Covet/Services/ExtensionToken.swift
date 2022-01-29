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
        
        let uid = self.getCurrentUserUID()
        let local = self.getLocalTokenComponent()
        let server = self.getServerTokenComponent()
        
        print("uid: " + (uid ?? "nil"))
        print("local: " + (local ?? "nil"))
        print("server: " + (server ?? "nil"))
        
        guard uid != nil && local != nil && server != nil else {
            return nil
        }
        
        return ExtensionAuthenticationPackage(uid: uid!, local: local!, server: server!)

    }

    private static func getCurrentUserUID() -> String? {
        Defaults.sharedSuite.string(forKey: "CurrentUserUID")
    }

    private static func getServerTokenComponent() -> String? {
        Defaults.sharedSuite.string(forKey: "ServerTokenComponent")
    }
    
    private static func getLocalTokenComponent() -> String? {
        Defaults.sharedSuite.string(forKey: "LocalTokenComponent")
    }

    
}

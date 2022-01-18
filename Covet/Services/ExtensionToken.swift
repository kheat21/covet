//
//  ExtensionTokewn.swift
//  Covet
//
//  Created by Covet on 1/18/22.
//

import Foundation

class ExtensionTokenService {
    
    func update() async -> Bool {
        do {
            let localTokenComponent = generateLocalToken()
            
            let resp = try await API.setExtensionToken(localTokenComponent: localTokenComponent)
            guard resp != nil else { return false }
            
        } catch {
            return false
        }
    }
    
    
    private func generateLocalToken() -> String {
        return Strings.randomString(length: 48)
    }
}

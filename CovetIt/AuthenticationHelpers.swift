//
//  AuthenticationHelpers.swift
//  CovetIt
//
//  Created by Covet on 1/28/22.
//

import Foundation

func isLoggedIn() -> Bool {
    return ExtensionTokenService.getTokens() != nil
}

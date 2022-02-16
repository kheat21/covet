//
//  RefreshUserButton.swift
//  Covet
//
//  Created by Covet on 2/16/22.
//

import SwiftUI

struct RefreshUserButton: View {
    
    // Shared auth state
    @EnvironmentObject var auth: AuthService
    
    var body: some View {
        if auth.gettingCurrentCovetUser {
            ProgressView()
        } else {
            Button(action: {
                self.auth.refreshUser()
            }, label: {
                Image(systemName: "goforward")
            })
        }
    }
}

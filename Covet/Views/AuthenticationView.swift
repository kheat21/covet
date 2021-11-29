//
//  AuthenticationView.swift
//  Covet
//
//  Created by Brendan Manning on 11/24/21.
//

import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image("Covet_Logo_BW")
                    .resizable()
                    .scaledToFit()
                    .padding([.leading, .trailing], 64)
                    .padding([.bottom], 32)
                Text("A whole new shopping experience (whatever subtitle you want)")
                    .padding([.leading, .trailing], 32)
                    .padding([.bottom], 16)
                Button(
                    action: {
                        AuthService.shared.signIn()
                    },
                    label: {
                        HStack {
                            Image("GoogleG")
                                .resizable()
                                .frame(width: 28, height: 28, alignment: Alignment.leading)
                                
                            Text("Sign in with Google")
                                .foregroundColor(Color.gray)
                                .padding(Edge.Set.trailing, 4)
                        }
                        .padding(8)
                        .cornerRadius(4)
                        .background(
                            Color.white.shadow(color: Color.gray, radius: 1.5, x: 0, y: 2)
                        )
                        .padding(4)
                    }
                )
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}

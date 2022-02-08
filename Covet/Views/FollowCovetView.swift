//
//  FollowCovetView.swift
//  Covet
//
//  Created by Covet on 2/3/22.
//

import AlertToast
import SwiftUI

struct FollowCovetView: View {
    @EnvironmentObject var auth: AuthService
    @State var isProcessingCovetFollow: Bool = false
    var body: some View {
        VStack {
            Spacer()
            Text("Looks like you're new!")
                .font(.system(.headline))
                .padding([.bottom], 8)
                .padding([.leading, .trailing], 32)
            Text("Why don't you start seeing some products by following @covet?")
                .font(.system(.subheadline))
                .padding([.bottom], 8)
                .padding([.leading, .trailing], 32)
                .multilineTextAlignment(.center)
            Button(action: {
                if !self.isProcessingCovetFollow {
                    followCovet()
                }
            }, label: {
                Text("Follow @covet")
                    .padding(.all, 8)
                    .foregroundColor(Color.white)
            })
                .background(Color.covetGreen())
                .cornerRadius(4)
            Spacer()
        }
        .toast(isPresenting: $isProcessingCovetFollow, alert: {
            AlertToast(displayMode: .alert, type: .loading, title: nil)
        })
    }
    private func followCovet() {
        Task {
            self.isProcessingCovetFollow = true
            do {
                if let relationship = try await API.followCovet() {
                    await auth.refreshUser()
                }
            } catch {}
            self.isProcessingCovetFollow = false
        }
    }
}

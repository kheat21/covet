//
//  GiftingView.swift
//  Covet
//

import SwiftUI

struct GiftingView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gifting")
                        .font(.system(size: 32, weight: .regular, design: .serif))
                    Text("Find the perfect gift, personalized by AI")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)

                VStack(spacing: 16) {
                    NavigationLink(destination: GiftInterestsView(context: GiftContext(recipientType: .myself))) {
                        GiftOptionCard(
                            icon: "sparkles",
                            title: "For Myself",
                            subtitle: "Treat yourself — based on your wishlist"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink(destination: GiftRecipientSetupView(recipientType: .anotherUser)) {
                        GiftOptionCard(
                            icon: "person.2.fill",
                            title: "For Another User",
                            subtitle: "Gift ideas based on their Covet page"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink(destination: GiftRecipientSetupView(recipientType: .external)) {
                        GiftOptionCard(
                            icon: "person.badge.plus",
                            title: "For Someone Not On The App",
                            subtitle: "Describe them and we'll find the perfect fit"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 40)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct GiftOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.covetGreen().opacity(0.12))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.covetGreen())
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(UIColor.systemGray3))
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
        )
    }
}

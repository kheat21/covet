//
//  Covet.swift
//  Covet
//
//  Created by Brendan Manning on 1/1/22.
//SearchView.swift

import Combine
import SwiftUI

class DeepLinkRouter: ObservableObject {
    enum Destination: Equatable {
        case profile(userId: Int)
        case post(userId: Int, postId: Int)
    }
    @Published var pending: Destination? = nil

    func handle(url: URL) {
        guard url.scheme == "covet" else { return }
        let parts = url.pathComponents.filter { $0 != "/" }
        switch url.host {
        case "profile":
            if let idStr = parts.first, let id = Int(idStr) {
                pending = .profile(userId: id)
            }
        case "post":
            if parts.count >= 2, let userId = Int(parts[0]), let postId = Int(parts[1]) {
                pending = .post(userId: userId, postId: postId)
            }
        default:
            break
        }
    }
}

// Identifiable wrapper for a user ID used in deep link sheets
private struct DeepLinkUserID: Identifiable {
    let id: Int
}

struct CovetView : View {

    @EnvironmentObject var auth: AuthService
    @EnvironmentObject var deepLinkRouter: DeepLinkRouter
    @State var showCreatePostView = false
    @State private var selectedTab: Int = 0

    // Deep link navigation state
    @State private var deepLinkProfileTarget: DeepLinkUserID? = nil
    @State private var deepLinkPostTarget: Post? = nil
    @State private var isResolvingDeepLink: Bool = false

    var body : some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                FeedView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Image("Covet_Logo_Colored")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 20)
                        }
                    }
            }
            .tabItem {
                Label("Feed", systemImage: "list.dash")
                    .foregroundColor(Color.covetGreen())
            }
            .tag(0)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                        .foregroundColor(Color.covetGreen())
                }
                .tag(1)

            if shouldShowBadge(currentCovetUser: auth.currentCovetUser) {
                ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                        .foregroundColor(Color.covetGreen())
                }
                .tag(2)
                .badge(badgeContents(currentCovetUser: auth.currentCovetUser))
            } else {
                ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                        .foregroundColor(Color.covetGreen())
                }
                .tag(2)
            }

            NavigationView {
                GiftingView()
            }
            .tabItem {
                Label("Gifting", systemImage: "shippingbox")
            }
            .tag(3)
        }
        .font(.headline)
        .accentColor(.covetGreen())
        .onAppear { selectedTab = 0 }
        .popover(isPresented: self.$showCreatePostView, content: {
            CreatePostView()
        })
        .onChange(of: deepLinkRouter.pending) { dest in
            guard let dest = dest else { return }
            deepLinkRouter.pending = nil
            switch dest {
            case .profile(let userId):
                deepLinkProfileTarget = DeepLinkUserID(id: userId)
            case .post(let userId, let postId):
                isResolvingDeepLink = true
                Task {
                    if let resp = try? await API.getUser(user_id: userId),
                       let post = resp.user?.posts?.first(where: { $0.id == postId }) {
                        await MainActor.run {
                            deepLinkPostTarget = post
                            isResolvingDeepLink = false
                        }
                    } else {
                        // Couldn't find post — fall back to showing the profile
                        await MainActor.run {
                            deepLinkProfileTarget = DeepLinkUserID(id: userId)
                            isResolvingDeepLink = false
                        }
                    }
                }
            }
        }
        .sheet(item: $deepLinkProfileTarget) { target in
            NavigationView {
                ProfileView(userId: target.id)
            }
        }
        .sheet(item: $deepLinkPostTarget, onDismiss: { deepLinkPostTarget = nil }) { post in
            PostView(post: post)
        }
    }
}

func shouldShowBadge(currentCovetUser: CovetUser?) -> Bool {
    guard let usr = currentCovetUser else { return false }
    return usr.countPendingIncoming() > 0
}

func badgeContents(currentCovetUser: CovetUser?) -> Int {
    return currentCovetUser!.countPendingIncoming()
}

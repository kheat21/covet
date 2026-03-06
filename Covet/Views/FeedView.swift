//
//  FeedView.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import AlertToast
import Combine
import Kingfisher
import SwiftUI

struct FeedView: View {
    
    @EnvironmentObject var auth: AuthService
    
    @State var isRefreshingTop = false
    @State var isFetching = false
    @State var currentPage: Int = 1
    @State var posts: [Post]? = nil
    @State var hiddenPostIds: Set<Int> = []
    
//    @State var openUser: CovetUser? = nil
    
    let image3 = "https://cdn.motor1.com/images/mgl/QeWez9/s1/001.jpg"
    
    func _fetchFirstPage() {
        _fetchNextPage(clearBeforeUpdating: true)
    }
    
    func _fetchNextPage(clearBeforeUpdating: Bool = false) {
        self.isFetching = true
        if clearBeforeUpdating {
            self.currentPage = 1
        }
        Task.detached {
            var items: [Post]? = nil
            do {
                items = try await API.getFeed(page: self.currentPage)
            } catch {}
            await self.updateUI(clear: clearBeforeUpdating, newItems: items)
        }
    }
    
    func updateUI(clear: Bool, newItems: [Post]?) {
        if let items = newItems {
            if self.posts == nil || clear {
                self.posts = []
            }
            for item in items {
                posts!.append(item)
            }
            self.posts = self.posts!.removingDuplicates()
            if items.count > 0 {
                self.currentPage += 1;
            }
        }
        self.isFetching = false
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // If the user just made their account, there will be no posts available AND
            // there will be no completed friend or follower requests yet
            if let user = auth.currentCovetUser, let posts = self.posts {
                
                if posts.count == 0 && user.isFollowingOrFriendingAnyone() == false {
                    FollowCovetView(onFollowed: {
                        self._fetchFirstPage()
                    })
                }
                            
                // Otherwise, just show whatever we got..
                else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            FeedHeaderView()
                            LazyVGrid(
                                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                                spacing: 16
                            ) {
                                ForEach(Array(posts.filter { !hiddenPostIds.contains($0.id) }.enumerated()), id: \.offset) { index, post in
                                    if let product = getProductForPost(post: post), let postUser = post.user {
                                        NavigationLink(destination: ProfileView(userId: postUser.id)
                                            .navigationBarTitle(postUser.username)) {
                                            FeedItemCard(
                                                product: product,
                                                user: postUser,
                                                onImageLoadFailed: { hiddenPostIds.insert(post.id) }
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .onAppear {
                                            if let lastPost = posts.last, lastPost.id == post.id, !self.isFetching {
                                                _fetchNextPage()
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                    }
                    .refreshable {
                        Task.detached {
                            self._fetchFirstPage()
                        }
                    }
                }
            }
        }
        .toast(isPresenting: $isFetching, alert: {
            AlertToast(displayMode: .alert, type: .loading, title: nil)
        })
//        .sheet(item: $openUser, onDismiss: nil, content: { item in
//            ProfileView(isLoggedInUser: false, otherUser: item)
//        })
        .task {
            _fetchFirstPage()
        }
    }
}

private struct FeedItemCard: View {
    let product: Product
    let user: CovetUser
    var onImageLoadFailed: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .bottomLeading) {
                KFImage(URL(string: product.image_url))
                    .onFailure { _ in onImageLoadFailed?() }
                    .resizable()
                    .scaledToFill()
                    .clipped()
                makeCovetC(size: 36, user: user, textSize: 11)
                    .padding(8)
            }
            .aspectRatio(0.8, contentMode: .fit)
            .clipped()
            .cornerRadius(4)

            VStack(alignment: .leading, spacing: 2) {
                if let vendor = product.vendor, !vendor.isEmpty {
                    Text(vendor.uppercased())
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fontWeight(.medium)
                }
                Text(product.name)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                if let price = product.price {
                    Text("$\(String(format: "%.0f", price))")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 2)
            .padding(.bottom, 8)
        }
    }
}

private struct FeedHeaderView: View {
    @State private var selectedPrice: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Curated for You")
                .font(.system(size: 32, weight: .regular, design: .serif))
                .padding(.top, 8)
            Text("Discover what others are coveting")
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack(spacing: 4) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("PRICE RANGE")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fontWeight(.medium)
            }
            .padding(.top, 8)
            HStack(spacing: 12) {
                Button(action: { selectedPrice = 0 }) {
                    Text("All Prices")
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedPrice == 0 ? Color.covetGreen() : Color(UIColor.systemGray5))
                        .foregroundColor(selectedPrice == 0 ? .white : .primary)
                        .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
                Button(action: { selectedPrice = 1 }) {
                    Text("Under $500")
                        .font(.subheadline)
                        .fontWeight(selectedPrice == 1 ? .semibold : .regular)
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 16)
    }
}

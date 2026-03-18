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
    @State var isInitialLoad = true
    @State var currentPage: Int = 1
    @State var posts: [Post]? = nil
    @State var hiddenPostIds: Set<Int> = []
    @State var selectedCategory: String = "All"
    @State private var columnCount: Int = 1
    
//    @State var openUser: CovetUser? = nil
    
    func _fetchFirstPage() {
        _fetchNextPage(clearBeforeUpdating: true)
    }
    
    
    func updateUI(clear: Bool, newItems: [Post]?, continueFetchingForCategory: String? = nil) {
        if let items = newItems {
            if self.posts == nil || clear {
                self.posts = []
            }
            for item in items {
                posts!.append(item)
            }
            self.posts = self.posts!.removingDuplicates().sorted { $0.createdAt > $1.createdAt }
            if items.count > 0 {
                self.currentPage += 1
                // If triggered by a category tap, keep fetching until API runs out
                if let cat = continueFetchingForCategory, self.selectedCategory == cat {
                    _fetchNextPage(continueFetchingForCategory: cat)
                    return
                }
            }
        }
        self.isFetching = false
        self.isInitialLoad = false
    }

    func _fetchNextPage(clearBeforeUpdating: Bool = false, continueFetchingForCategory: String? = nil) {
        self.isFetching = true
        if clearBeforeUpdating { self.currentPage = 1 }
        Task.detached {
            var items: [Post]? = nil
            do { items = try await API.getFeed(page: self.currentPage) } catch {}
            await self.updateUI(clear: clearBeforeUpdating, newItems: items, continueFetchingForCategory: continueFetchingForCategory)
        }
    }

    func selectCategory(_ category: String, scrollProxy: ScrollViewProxy? = nil) {
        selectedCategory = category
        scrollProxy?.scrollTo("feedTop", anchor: .top)
        guard category != "All", !isFetching else { return }
        // Fetch pages until the API runs out of results
        _fetchNextPage(continueFetchingForCategory: category)
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
                    let filteredPosts = posts.filter { post in
                        guard !hiddenPostIds.contains(post.id) else { return false }
                        guard selectedCategory != "All" else { return true }
                        if let product = getProductForPost(post: post) {
                            return guessCategory(for: product) == selectedCategory
                        }
                        return false
                    }
                    VStack(spacing: 0) {
                        ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            Color.clear.frame(height: 0).id("feedTop")
                            FeedHeaderView(selectedCategory: $selectedCategory, onCategoryTap: { cat in selectCategory(cat, scrollProxy: scrollProxy) })
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible()), count: columnCount),
                                spacing: 16
                            ) {
                                ForEach(Array(filteredPosts.enumerated()), id: \.offset) { index, post in
                                    if let product = getProductForPost(post: post), let postUser = post.user {
                                        NavigationLink(destination: PostView(post: post)) {
                                            FeedItemCard(
                                                product: product,
                                                user: postUser,
                                                coveted: (post.coveted ?? 0) == 1,
                                                onImageLoadFailed: { hiddenPostIds.insert(post.id) }
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .onAppear {
                                            if filteredPosts.last?.id == post.id && !self.isFetching {
                                                _fetchNextPage()
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            if isFetching && !isInitialLoad {
                                ProgressView()
                                    .padding(.vertical, 16)
                            }
                            Color.clear.frame(height: 24)
                        }
                    }
                    .refreshable {
                        Task.detached {
                            self._fetchFirstPage()
                        }
                    }
                    } // end ScrollViewReader
                    } // end VStack
                }
            }
        }
        .toast(isPresenting: $isInitialLoad, alert: {
            AlertToast(displayMode: .alert, type: .loading, title: nil)
        })
//        .sheet(item: $openUser, onDismiss: nil, content: { item in
//            ProfileView(isLoggedInUser: false, otherUser: item)
//        })
        .task {
            _fetchFirstPage()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button(action: { columnCount = 1 }) {
                        Image(systemName: "rectangle.portrait")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(columnCount == 1 ? Color.covetGreen() : Color(UIColor.systemGray3))
                    }
                    .accessibilityLabel("Single column view")
                    Button(action: { columnCount = 2 }) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(columnCount == 2 ? Color.covetGreen() : Color(UIColor.systemGray3))
                    }
                    .accessibilityLabel("Two column view")
                }
            }
        }
    }
}

private struct FeedItemCard: View {
    let product: Product
    let user: CovetUser
    var coveted: Bool = false
    var onImageLoadFailed: (() -> Void)? = nil
    @State private var scrapedPrice: Double? = nil
    @State private var fallbackImageURL: String? = nil
    @State private var isScraping: Bool = false

    private var activeImageURL: String {
        fallbackImageURL ?? product.image_url
    }

    private var displayPrice: Double? {
        if let p = product.price, p > 0 { return p }
        return scrapedPrice
    }

    private var isOnSale: Bool {
        guard let original = product.price, original > 0,
              let current = scrapedPrice, current > 0 else { return false }
        return current < original * 0.95
    }

    private func handleImageFailure() {
        // If we already tried a fallback and it also failed, hide the post
        if fallbackImageURL != nil {
            onImageLoadFailed?()
            return
        }
        // First failure: try re-scraping the product link for a fresh image URL
        guard !isScraping, !product.link.isEmpty else {
            onImageLoadFailed?()
            return
        }
        isScraping = true
        Task {
            if let scraped = await scrapeProduct(urlString: product.link),
               let freshURL = scraped.imageURL, !freshURL.isEmpty,
               freshURL != product.image_url {
                await MainActor.run { fallbackImageURL = freshURL }
            } else {
                await MainActor.run { onImageLoadFailed?() }
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Color.clear
                .aspectRatio(0.8, contentMode: .fit)
                .overlay(
                    KFImage(URL(string: activeImageURL))
                        .onFailure { _ in handleImageFailure() }
                        .resizable()
                        .scaledToFill()
                        .clipped()
                )
                .overlay(
                    makeCovetC(size: 36, user: user, textSize: 11)
                        .padding(8),
                    alignment: .bottomLeading
                )
                .overlay(
                    Group {
                        if coveted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                                .padding(8)
                        }
                    },
                    alignment: .topLeading
                )
                .overlay(
                    Group {
                        if isOnSale {
                            Text("SALE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.covetGreen())
                                .cornerRadius(4)
                                .padding(6)
                        }
                    },
                    alignment: .topTrailing
                )
                .cornerRadius(6)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.covetGreen(), lineWidth: 4)
                )

            let parsed = parseProductDisplay(name: product.name, vendor: product.vendor)
            VStack(alignment: .leading, spacing: 3) {
                if let brand = parsed.brand, !brand.isEmpty {
                    Text(brand.uppercased())
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                Text(parsed.cleanName)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                if isOnSale, let original = product.price, let saleStr = formatPrice(scrapedPrice) {
                    HStack(spacing: 4) {
                        Text(formatPrice(original) ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .strikethrough()
                        Text(saleStr)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                } else if let priceStr = formatPrice(displayPrice) {
                    Text(priceStr)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
            .frame(height: 82, alignment: .topLeading)
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
        )
        .task {
            guard (product.price == nil || product.price == 0), !product.link.isEmpty else { return }
            if let scraped = await scrapeProduct(urlString: product.link),
               let priceStr = scraped.price,
               let price = Double(priceStr), price > 0 {
                scrapedPrice = price
            }
        }
    }
}

private struct FeedHeaderView: View {
    @Binding var selectedCategory: String
    var onCategoryTap: (String) -> Void = { _ in }

    static let categories = ["All", "Clothing", "Shoes", "Accessories", "Home", "Beauty", "Tech"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            (
                Text("Take the ")
                + Text("if").foregroundColor(Color.covetGreen())
                + Text(" out of g")
                + Text("if").foregroundColor(Color.covetGreen())
                + Text("t giving")
            )
            .font(.system(size: 26, weight: .regular, design: .serif))
            .padding(.top, 16)
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FeedHeaderView.categories, id: \.self) { category in
                        Button(action: { onCategoryTap(category) }) {
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Color.covetGreen() : Color(UIColor.systemGray6))
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .cornerRadius(20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel("\(category) filter\(selectedCategory == category ? ", selected" : "")")
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 8)
        }
    }
}

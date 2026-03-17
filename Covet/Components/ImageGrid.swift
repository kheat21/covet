//
//  ImageGrid.swift
//  Covet
//
//  Created by Covet on 1/13/22.
//

import SwiftUI

struct ImageGrid: View {

    var images: [Post]
    var selected: (_: Post) -> Void

    private let gridItems = [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]

    // Uncoveted posts first (by date desc), coveted posts last
    private var sortedImages: [Post] {
        let uncoveted = images.filter { ($0.coveted ?? 0) == 0 }
        let coveted   = images.filter { ($0.coveted ?? 0) == 1 }
        return uncoveted + coveted
    }

    var body: some View {
        let posts = sortedImages
        LazyVGrid(columns: gridItems, spacing: 0) {
            ForEach(Array(posts.enumerated()), id: \.offset) { index, element in
                ImageGridCell(
                    post: element,
                    index: index,
                    total: posts.count,
                    onTap: { self.selected(element) }
                )
            }
        }
    }
    
}

private struct ImageGridCell: View {
    let post: Post
    let index: Int
    let total: Int
    let onTap: () -> Void

    @State private var fallbackImageURL: String? = nil
    @State private var hidden: Bool = false
    @State private var isScraping: Bool = false

    private var imageURL: String {
        fallbackImageURL ?? (getProductForPost(post: post)?.image_url ?? "")
    }

    private func handleImageFailure() {
        if fallbackImageURL != nil {
            hidden = true
            return
        }
        guard !isScraping,
              let link = getProductForPost(post: post)?.link, !link.isEmpty else {
            hidden = true
            return
        }
        isScraping = true
        Task {
            if let scraped = await scrapeProduct(urlString: link),
               let freshURL = scraped.imageURL, !freshURL.isEmpty,
               freshURL != getProductForPost(post: post)?.image_url {
                await MainActor.run { fallbackImageURL = freshURL }
            } else {
                await MainActor.run { hidden = true }
            }
        }
    }

    var body: some View {
        if !hidden {
            GeometryReader { gr in
                ZStack(alignment: .topLeading) {
                    CovetSquareZoomedInItem(
                        url: imageURL,
                        size: gr.size.width,
                        topBorderWidth: 4,
                        leftBorderWidth: 4,
                        bottomBorderWidth: index >= total - 3 ? 4 : 0,
                        rightBorderWidth: (index % 3 == 2 || index == total - 1) ? 4 : 0,
                        onImageLoadFailed: handleImageFailure
                    )
                    .onTapGesture { onTap() }

                    if (post.coveted ?? 0) == 1 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                            .padding(6)
                    }
                }
            }
            .clipped()
            .aspectRatio(1, contentMode: .fit)
        }
    }
}

//struct ImageGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageGrid(images: [
//            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Temple_T_logo.svg/905px-Temple_T_logo.svg.png",
//            "https://cdn.shopify.com/s/files/1/0050/0182/products/AGingersSoul_3Q_1000x_70459821-7f81-4bd3-a36d-a2b853c430f0.jpg?v=1622118317",
//            "https://www.thespruce.com/thmb/5ZpyukLcBAS448-r2P43k9wDmEs=/3360x2240/filters:fill(auto,1)/signs-to-replace-your-couch-4165258-hero-5266fa7b788c41f6a02f24224a5de29b.jpg",
//            "https://i.insider.com/5a4f6ba3c32ae634008b49f0?width=800&format=jpeg",
//            "https://www.womansworld.com/wp-content/uploads/sites/2/2018/05/tjmaxx-handbags.jpg",
//            "https://images.squarespace-cdn.com/content/v1/5c479b7f710699200cbe95de/1553910021271-2PJYW4J4THGDNDUECDGD/TjMaxx-Interior%28web%2913.jpg",
//            "https://www.bostonherald.com/wp-content/uploads/migration/2016/05/04/050416maxnl05.jpg"
//        ]) { i in
//            print("Selected at index " + String(i))
//        }
//    }
//}

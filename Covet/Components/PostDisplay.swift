//
//  PostDisplay.swift
//  Covet
//
//  Created by Covet on 1/24/22.
//

import Foundation
import SwiftUI

struct PostDisplay : View {

    @State var post: Post

    var body : some View {
        if let product = getProductForPost(post: self.post) {

            GeometryReader { geo in
                CovetSquareZoomedInItem(
                    url: product.image_url,
                    size: geo.size.width,
                    topBorderWidth: 4,
                    leftBorderWidth: 4,
                    bottomBorderWidth: 4,
                    rightBorderWidth: 4
                )
            }
            .aspectRatio(1, contentMode: .fit)
            .padding([.bottom], 16)
            .onTapGesture {
                self.post.products?.first?.link.tryToOpenAsURL()
            }
            //.allowsHitTesting(false)
            
            let parsed = parseProductDisplay(name: product.name, vendor: product.vendor)
            VStack(spacing: 4) {
                if let brand = parsed.brand, !brand.isEmpty {
                    Text(brand.uppercased())
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                        .tracking(0.5)
                }
                Text(parsed.cleanName)
                    .font(.system(size: 22, weight: .regular, design: .default))
                    .multilineTextAlignment(.center)
                if let priceStr = formatPrice(product.price) {
                    Text(priceStr)
                        .font(.system(size: 18, weight: .semibold, design: .default))
                }
            }
            .padding([.top, .bottom], 8)
            
            if let caption = self.post.text {
                Text(caption)
                    .lineLimit(5)
                    .font(.system(size: 18, weight: .thin, design: .rounded))
                    .padding([.leading, .trailing], 16)
            }
             
        }
    }
}

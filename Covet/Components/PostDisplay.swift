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
            
            
            CovetSquareZoomedInItem(
                url: product.image_url,
                size: 250,
                topBorderWidth: 4,
                leftBorderWidth: 4,
                bottomBorderWidth: 4,
                rightBorderWidth: 4
            )
            .padding([.bottom], 16)
            .onTapGesture {
                self.post.products![0].link.tryToOpenAsURL()
            }
            //.allowsHitTesting(false)
            
            Text(product.name)
                    .font(.system(size: 24, weight: .regular, design: .default))
            
            HStack {
                if let productVendor = product.vendor {
                    Text(productVendor)
                        .font(.system(size: 20, weight: .regular, design: .default))
                }
                if let productPrice = product.price {
                    Text("$" + String(productPrice))
                        .font(.system(size: 20, weight: .semibold, design: .default))
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

//
//  ImageGrid.swift
//  Covet
//
//  Created by Covet on 1/13/22.
//

import SwiftUI

struct ImageGrid: View {
    
    var images: [String]
    
    private let gridItems = [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]
    
    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 0) {
            ForEach(0..<images.count) { i in
                GeometryReader { gr in
                    CovetSquareZoomedInItem(
                        url: images[i],
                        size: gr.size.width,
                        topBorderWidth: getTopBorderWidth(index: i),
                        leftBorderWidth: getLeftBorderWidth(index: i),
                        bottomBorderWidth: getBottomBorderWidth(index: i, total: images.count),
                        rightBorderWidth: getRightBorderWidth(index: i, total: images.count)
                    )
                        //.frame(height: gr.size.width)
                }
                .clipped()
                .aspectRatio(1, contentMode: .fit)
            }
        }
    }
    
    func getTopBorderWidth(index: Int) -> CGFloat {
        return 4;
    }
    
    func getBottomBorderWidth(index: Int, total: Int) -> CGFloat {
        return index >= total - 3 ? 4 : 0;
    }
    
    func getLeftBorderWidth(index: Int) -> CGFloat {
        return 4;
    }
    
    func getRightBorderWidth(index: Int, total: Int) -> CGFloat {
        return (index % 3 == 2 || index == total - 1) ? 4 : 0;
    }
}

struct ImageGrid_Previews: PreviewProvider {
    static var previews: some View {
        ImageGrid(images: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Temple_T_logo.svg/905px-Temple_T_logo.svg.png",
            "https://cdn.shopify.com/s/files/1/0050/0182/products/AGingersSoul_3Q_1000x_70459821-7f81-4bd3-a36d-a2b853c430f0.jpg?v=1622118317",
            "https://www.thespruce.com/thmb/5ZpyukLcBAS448-r2P43k9wDmEs=/3360x2240/filters:fill(auto,1)/signs-to-replace-your-couch-4165258-hero-5266fa7b788c41f6a02f24224a5de29b.jpg",
            "https://i.insider.com/5a4f6ba3c32ae634008b49f0?width=800&format=jpeg",
            "https://www.womansworld.com/wp-content/uploads/sites/2/2018/05/tjmaxx-handbags.jpg",
            "https://images.squarespace-cdn.com/content/v1/5c479b7f710699200cbe95de/1553910021271-2PJYW4J4THGDNDUECDGD/TjMaxx-Interior%28web%2913.jpg",
            "https://www.bostonherald.com/wp-content/uploads/migration/2016/05/04/050416maxnl05.jpg"
        ])
    }
}

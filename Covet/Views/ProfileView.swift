//
//  ProfileView.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI

struct ProfileView: View {
    
    let items = [
        "https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Temple_T_logo.svg/905px-Temple_T_logo.svg.png",
        "https://cdn.shopify.com/s/files/1/0050/0182/products/AGingersSoul_3Q_1000x_70459821-7f81-4bd3-a36d-a2b853c430f0.jpg?v=1622118317",
        "https://www.thespruce.com/thmb/5ZpyukLcBAS448-r2P43k9wDmEs=/3360x2240/filters:fill(auto,1)/signs-to-replace-your-couch-4165258-hero-5266fa7b788c41f6a02f24224a5de29b.jpg",
        "https://i.insider.com/5a4f6ba3c32ae634008b49f0?width=800&format=jpeg",
        "https://www.womansworld.com/wp-content/uploads/sites/2/2018/05/tjmaxx-handbags.jpg",
        "https://images.squarespace-cdn.com/content/v1/5c479b7f710699200cbe95de/1553910021271-2PJYW4J4THGDNDUECDGD/TjMaxx-Interior%28web%2913.jpg",
        "https://www.bostonherald.com/wp-content/uploads/migration/2016/05/04/050416maxnl05.jpg"
    ];
    
    private var gridItems = [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]

    var body: some View {
        VStack {
            CovetItem(url: items[0])
                .frame(width: nil, height: 250, alignment: Alignment.center)
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 0) {
                    ForEach(0..<items.count) { i in
                        GeometryReader { gr in
                            CovetGridItem(url: items[i])
                                .frame(height: gr.size.width)
                        }
                        .clipped()
                        .aspectRatio(1, contentMode: .fit)
                        .border(width: getTopBorderWidth(index: i), edges: [.top], color: Color.green)
                        .border(width: getLeftBorderWidth(index: i), edges: [.leading], color: Color.green)
                        .border(width: getBottomBorderWidth(index: i, total: items.count), edges: [.bottom], color: Color.green)
                        .border(width: getRightBorderWidth(index: i), edges: [.trailing], color: Color.green)
                    }
                }
            }
        }
        
        
    }
    
    
    func getTopBorderWidth(index: Int) -> CGFloat {
        if(index < 3) {
            return 4;
        } else {
            return 4/2;
        }
    }
    
    func getBottomBorderWidth(index: Int, total: Int) -> CGFloat {
        if(total - index < 3) {
            return 4;
        } else {
            return 4/2;
        }
    }
    
    func getLeftBorderWidth(index: Int) -> CGFloat {
        if(index % 3 == 0) {
            return 4;
        } else {
            return 4/2;
        }
    }
    
    func getRightBorderWidth(index: Int) -> CGFloat {
        if(index % 3 == 2) {
            return 4;
        } else {
            return 4/2;
        }
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

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
                            CovetSquareZoomedInItem(
                                url: items[i],
                                size: gr.size.width,
                                topBorderWidth: getTopBorderWidth(index: i),
                                leftBorderWidth: getLeftBorderWidth(index: i),
                                bottomBorderWidth: getBottomBorderWidth(index: i, total: items.count),
                                rightBorderWidth: getRightBorderWidth(index: i, total: items.count)
                            )
                                //.frame(height: gr.size.width)
                        }
                        .clipped()
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        
        
        
    }
    
    
    func getTopBorderWidth(index: Int) -> CGFloat {
        print("(top) i=" + String(index))
        return 4;
        if(index < 3) {
            return 4;
        } else {
            return 0; // 4/2;
        }
    }
    
    func getBottomBorderWidth(index: Int, total: Int) -> CGFloat {
        
        return index >= total - 3 ? 4 : 0;
        
//        print("(bottom) i=" + String(index))
//        
//        var count_in_last_row = total % 3
//        count_in_last_row = count_in_last_row == 0 ? 3 : count_in_last_row
//        
//        print("\tcount in last row: " + String(count_in_last_row))
//        
//        let minimum_last_row_index = total - count_in_last_row;
//        
//        print("\tminimum last row index: " + String(minimum_last_row_index))
//        
//        return (index >= minimum_last_row_index) ? 4 : 0;
        
    }
    
    func getLeftBorderWidth(index: Int) -> CGFloat {
        print("(left) i=" + String(index))
        return 4;
        if(index % 3 == 0) {
            return 4;
        } else {
            return 0; //4/2;
        }
    }
    
    func getRightBorderWidth(index: Int, total: Int) -> CGFloat {
        print("(right) i=" + String(index))
        if(index % 3 == 2 || index == total - 1) {
            return 4;
        } else {
            return 0; //4/2;
        }
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

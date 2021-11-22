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
        "https://www.thespruce.com/thmb/5ZpyukLcBAS448-r2P43k9wDmEs=/3360x2240/filters:fill(auto,1)/signs-to-replace-your-couch-4165258-hero-5266fa7b788c41f6a02f24224a5de29b.jpg"
    ];
    
    private var gridItems = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    private var symbols = ["keyboard", "hifispeaker.fill", "printer.fill", "tv.fill", "desktopcomputer", "headphones", "tv.music.note", "mic", "plus.bubble", "video"]
    
    private var colors: [Color] = [.yellow, .purple, .green]
    
    var body: some View {
        VStack {
            CovetItem(url: items[0])
                .frame(width: nil, height: 250, alignment: Alignment.center)
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach((0...2), id: \.self) {
                        CovetItem(url: items[$0])
                            .font(.system(size: 30))
                            .frame(minWidth: 50, maxWidth: .infinity, minHeight: 150, maxHeight: 250)
                            .background(colors[$0 % colors.count])
                            .cornerRadius(10)
                    }
                }
            }
        }
        
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

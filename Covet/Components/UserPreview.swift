//
//  UserPreview.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI

struct UserPreview: View {
    
    let userAbbr: String;
    let topItem: String;
    
    var body: some View {
        HStack {
            CovetC(size: 60)
                .padding(Edge.Set.leading, 0)
            CovetSquareZoomedInItem(url: topItem, size: 250)
                
        }
        .frame(width: .infinity, height: 250, alignment: Alignment.center)
        .background(Color.accentColor)
    }
}

struct UserPreview_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
        //UserPreview(userAbbr: "BAM", topItem: "https://cdn.motor1.com/images/mgl/QeWez9/s1/001.jpg")
    }
}

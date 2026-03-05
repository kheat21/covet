//
//  UserPreview.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI

struct UserPreview: View {
    
    let user: CovetUser;
    let topItem: String;
    var onImageLoadFailed: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            makeCovetC(size: 60, user: user)
                .padding(Edge.Set.leading, 0)
            CovetSquareZoomedInItem(
                url: topItem, size: AppConfig.getCovetImageWidth(),
                topBorderWidth: 4,
                leftBorderWidth: 4,
                bottomBorderWidth: 4,
                rightBorderWidth: 4,
                onImageLoadFailed: onImageLoadFailed
            )
        }
    }
}

struct UserPreview_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
        //FeedView()
        //UserPreview(userAbbr: "BAM", topItem: "https://cdn.motor1.com/images/mgl/QeWez9/s1/001.jpg")
    }
}

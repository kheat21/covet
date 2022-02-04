//
//  CovetItem.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI
import UIKit
import Kingfisher


struct CovetSquareBlurredItem: View {
    
    var url: String
    var size: CGFloat
    
    var body: some View {
        AsyncImage(
            url: URL(string: self.url),
            content: { image in
                ZStack {
                    
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipped()
                        .zIndex(0)
                    
                    VisualEffectView(effect: UIBlurEffect(style: .light))
                    
                    image
                        .resizable()
                        .scaledToFit()
                        .zIndex(1)
            
                }
            },
            placeholder: {
                ProgressView()
            }
        )
        .frame(width: size, height: size, alignment: Alignment.center)
        .border(Color.covetGreen(), width: 4)
        
            
    }

    
}

struct CovetSquareZoomedInItem: View {
    
    var url: String
    var size: CGFloat
    
    var topBorderWidth: CGFloat?
    var leftBorderWidth: CGFloat?
    var bottomBorderWidth: CGFloat?
    var rightBorderWidth: CGFloat?
    
    var body: some View {
        KFImage.url(URL(string: self.url))
          .loadDiskFileSynchronously()
          //.cacheMemoryOnly()
          .onProgress { receivedSize, totalSize in  }
          .onSuccess { result in  }
          .onFailure { error in }
          .resizable()
          .scaledToFill()
          .frame(width: size, height: size)
          .clipped()
          .border(width: topBorderWidth ?? 0, edges: [.top], color: Color.covetGreen())
          .border(width: leftBorderWidth ?? 0, edges: [.leading], color: Color.covetGreen())
          .border(width: bottomBorderWidth ?? 0, edges: [.bottom], color: Color.covetGreen())
          .border(width: rightBorderWidth ?? 0, edges: [.trailing], color: Color.covetGreen())
        
        /*
        AsyncImage(
            url: URL(string: self.url),
            content: { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipped()
                        .border(width: topBorderWidth ?? 0, edges: [.top], color: Color.covetGreen())
                        .border(width: leftBorderWidth ?? 0, edges: [.leading], color: Color.covetGreen())
                        .border(width: bottomBorderWidth ?? 0, edges: [.bottom], color: Color.covetGreen())
                        .border(width: rightBorderWidth ?? 0, edges: [.trailing], color: Color.covetGreen())
                
            },
            placeholder: {
                ProgressView()
                    .frame(width: size, height: size, alignment: SwiftUI.Alignment.center)
            }
        )
        */
    }
}

struct CovetItem_Previews: PreviewProvider {
    static var previews: some View {
        CovetSquareZoomedInItem(url: "https://cdn.motor1.com/images/mgl/QeWez9/s1/001.jpg", size: 200)
    }
}

//
//  CovetItem.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI
import UIKit

struct CovetItem: View {
    
    var url: String
    var size: Int?
        
    var body: some View {
        AsyncImage(
            url: URL(string: self.url),
            content: { image in
                ZStack {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
//                        .frame(width: getSize(), height: getSize())
                }
                .cornerRadius(0) // Necessary for working
                .border(Color.green, width: 8)
            },
            placeholder: {
                ProgressView()
            }
        )
    }
    
    func getSize() -> CGFloat {
        return self.size == nil ? CGFloat(200) : CGFloat(self.size!)
    }
}

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
                        //.blur(radius: 8)
                        //.background(Color.green)
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
        .border(Color.green, width: 4)
        
            
    }

    
}

struct CovetSquareItem: View {
    
    var url: String
    var size: Int
    
    var body: some View {
        CovetGridItem(url: url)
            .scaledToFit()
            .frame(width: size.toCGFloat(), height: size.toCGFloat(), alignment: Alignment.center)
            
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
        AsyncImage(
            url: URL(string: self.url),
            content: { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipped()
                        .border(width: topBorderWidth ?? 0, edges: [.top], color: Color.green)
                        .border(width: leftBorderWidth ?? 0, edges: [.leading], color: Color.green)
                        .border(width: bottomBorderWidth ?? 0, edges: [.bottom], color: Color.green)
                        .border(width: rightBorderWidth ?? 0, edges: [.trailing], color: Color.green)
                
            },
            placeholder: {
                ProgressView()
            }
        )

    }
    
}


struct CovetGridItem: View {
    
    var url: String
    
    var body: some View {
        AsyncImage(
            url: URL(string: self.url),
            content: { image in
                ZStack {
//                    image
//                        .resizable()
//                        .clipped()
//                        .aspectRatio(contentMode: SwiftUI.ContentMode.fill)
//                        .scaledToFill()
//                        .blur(radius: 8)
//                        .zIndex(1)
                    image
                        .resizable()
                        .scaledToFit()
                        .zIndex(2)
                }
            },
            placeholder: {
                ProgressView()
            }
        )
    }
}

struct CovetItem_Previews: PreviewProvider {
    static var previews: some View {
        //CovetItem(url: "https://cdn.motor1.com/images/mgl/QeWez9/s1/001.jpg")
        //CovetGridItem(url: "https://cdn.motor1.com/images/mgl/QeWez9/s1/001.jpg")
        CovetSquareZoomedInItem(url: "https://cdn.motor1.com/images/mgl/QeWez9/s1/001.jpg", size: 200)
    }
}

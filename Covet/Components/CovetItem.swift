//
//  CovetItem.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI

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
                        .frame(width: getSize(), height: getSize())
                }
                .cornerRadius(0) // Necessary for working
                .frame(width: getSize(), height: getSize())
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

struct CovetItem_Previews: PreviewProvider {
    static var previews: some View {
        CovetItem(url: "https://cdn.motor1.com/images/mgl/QeWez9/s1/001.jpg")
    }
}

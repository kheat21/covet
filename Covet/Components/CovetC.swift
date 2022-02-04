//
//  CovetC.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI

func makeCovetC(size: Int, user: CovetUser, textSize: CGFloat = 14.0) -> some View {
    let messageBasedOnName = getInitials(str: user.name ?? "")
    let messageBasedOnUsername = getInitials(str: user.username)
    if messageBasedOnName.count > 0 {
        return CovetC(size: size, text: messageBasedOnName, textSize: textSize)
    } else {
        return CovetC(size: size, text: messageBasedOnUsername, textSize: textSize)
    }
}

struct CovetC: View {
    
    var size: Int
    var text: String = ""
    var textSize: CGFloat = 14.0
    
    var body: some View {
        ZStack(alignment: Alignment.center) {
            Text(text)
                .font(.system(size: self.textSize, weight: .medium, design: .default))
                .padding(Edge.Set.leading, 2)
            Image("Covet_C")
                .resizable()
                .scaledToFill() // <=== Saves aspect ratio
                .frame(width: CGFloat(size), height: CGFloat(size))
        }
    }
}

struct CovetC_Previews: PreviewProvider {
    static var previews: some View {
        CovetC(size: 60)
    }
}

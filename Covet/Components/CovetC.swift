//
//  CovetC.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI

struct CovetC: View {
    
    var size: Int
    
    var body: some View {
        ZStack(alignment: Alignment.center) {
            Text("BM");
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

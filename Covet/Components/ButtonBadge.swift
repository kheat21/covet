//
//  ButtonBadge.swift
//  Covet
//
//  Created by Covet on 2/15/22.
//

import SwiftUI

struct ButtonBadge: View {

    let message: String

    var body: some View {
        ZStack {
            HStack {
                VStack {
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white)
                        .padding(6)
                        .background(Color.covetGreen())
                        .clipShape(Circle())
                    Spacer()
                        .frame(height: 16)
                }
                Spacer()
            }
        }
        .allowsHitTesting(false)
    }
    
}

struct ButtonBadge_Previews: PreviewProvider {
    static var previews: some View {
        ButtonBadge(message: "Hello World")
    }
}

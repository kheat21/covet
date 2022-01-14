//
//  Chip.swift
//  Covet
//
//  Created by Brendan Manning on 12/28/21.
//

import SwiftUI

struct Chip: View {
    
    @State var preIcon: String?;
    @State var text: String;
    @State var color: Color;
    
    var body: some View {
        ZStack {
            HStack {
                if let icon = preIcon {
                    Label(text, systemImage: icon)
                } else {
                    Text(text)
                }
            }
            .padding(4)
            .font(.system(size: 14, weight: .light, design: .default))
        }
        .background(color)
        .cornerRadius(8)
    }
    
}

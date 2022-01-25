//
//  CovetC.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import SwiftUI
import SwiftUITooltip

struct CovetC: View {
    
    var size: Int
    var text: String
    
    @State var isTooltipShowing: Bool = false
    
    private var tooltipConfig = DefaultTooltipConfig()
    
    init(size: Int, text: String = "BM") {
        
        self.size = size
        self.text = text
        
        self.tooltipConfig.enableAnimation = false
        self.tooltipConfig.animationOffset = 10
        self.tooltipConfig.animationTime = 1
        self.tooltipConfig.margin = 0
        self.tooltipConfig.contentPaddingTop = 16
        self.tooltipConfig.contentPaddingLeft = 16
        self.tooltipConfig.contentPaddingRight = 16
        self.tooltipConfig.contentPaddingBottom = 16
        self.tooltipConfig.showArrow = false
        self.tooltipConfig.borderColor = Color.covetGreen()
        self.tooltipConfig.backgroundColor = Color.covetGreen()
    
    }
    
    var body: some View {
        
        if self.isTooltipShowing {
            self.buildCovetC(imageSize: 0, fontSize: 0, fontWeight: .thin)
                .tooltip(.trailingBottom, config: tooltipConfig) {
                    Text("Something nice!").foregroundColor(Color.white)
            }
            .onTapGesture {
                self.isTooltipShowing = false
            }
        } else {
            self.buildCovetC(imageSize: 0, fontSize: 0, fontWeight: .thin)
                .onTapGesture {
                    self.isTooltipShowing = true
                }
        }
        
    }
    
    private func buildCovetC(imageSize: Int, fontSize: Int, fontWeight: Font.Weight) -> some View {
        return (
            ZStack(alignment: Alignment.center) {
                Text(text)
                    .font(.system(size: 10, weight: .bold, design: .default))
                    .padding(Edge.Set.leading, 2)
                Image("Covet_C")
                    .resizable()
                    .scaledToFill() // <=== Saves aspect ratio
                    .frame(width: CGFloat(size), height: CGFloat(size))
            }
        )
    }
}

struct CovetC_Previews: PreviewProvider {
    static var previews: some View {
        CovetC(size: 60)
    }
}

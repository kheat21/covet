//
//  View.swift
//  Covet
//
//  Created by Brendan Manning on 11/23/21.
//

import SwiftUI

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }

    @ViewBuilder
    func presentationDetentsMediumIfAvailable() -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDetents([.medium])
        } else {
            self
        }
    }
}

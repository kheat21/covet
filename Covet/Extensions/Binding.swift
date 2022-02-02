//
//  Binding.swift
//  Covet
//
//  Created by Covet on 2/2/22.
//

import Combine
import SwiftUI

extension Binding where Value == Bool {
    static func && (lhs: Binding<Bool>, rhs: Binding<Bool>) -> Binding<Bool> {
        return Binding<Bool>(
            get: { lhs.wrappedValue && rhs.wrappedValue },
            set: {_ in
                print("Not implemented")
            }
        )
    }
}

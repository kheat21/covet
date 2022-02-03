//
//  KeyboardHelper.swift
//  Covet
//
//  Created by Covet on 2/3/22.
//

import UIKit

class KeyboardHelper {
    static func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

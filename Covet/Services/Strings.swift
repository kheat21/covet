//
//  Strings.swift
//  Covet
//
//  Created by Covet on 1/18/22.
//

import Foundation

class Strings {

    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var str = ""
        for _ in 0 ..< length {
            str += String(letters.randomElement()!)
        }
        return str
    }
    
}

//
//  JSONDictionary.swift
//  Covet
//
//  Created by Brendan Manning on 1/1/22.
//

import Foundation

extension JSDict {
    func stringify() -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: data, encoding: String.Encoding.utf8) ?? ""
        } catch {
            return ""
        }
    }

}

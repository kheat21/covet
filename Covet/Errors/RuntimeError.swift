//
//  RuntimeError.swift
//  Covet
//
//  Created by Brendan Manning on 11/29/21.
//

import Foundation

struct RuntimeError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
}

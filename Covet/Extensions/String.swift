//
//  String.swift
//  Covet
//
//  Created by Brendan Manning on 12/29/21.
//

import Foundation


extension String {
    
    func isoStringToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:self)!
        return date
    }
    
    func firstCharacter() -> String {
        let index = self.index(self.startIndex, offsetBy: 1)
        return String(self[..<index])
    }
    
}

//
//  PostArray.swift
//  Covet
//
//  Created by Covet on 2/5/22.
//

import Foundation

extension Array where Element == Post {
    func removingDuplicates() -> [Post] {
        var result = [Post]()
        var seen = Set<Post>()
        for value in self {
            if seen.insert(value).inserted {
                result.append(value)
            }
        }
        return result
    }
}

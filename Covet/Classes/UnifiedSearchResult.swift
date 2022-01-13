//
//  UnifiedSearchResult.swift
//  Covet
//
//  Created by Covet on 1/12/22.
//

import Foundation
import SwiftyJSON

class UnifiedSearchResult: Decodable {
    
    private(set) var users: [CovetUser];
    private(set) var posts: [Post];

}

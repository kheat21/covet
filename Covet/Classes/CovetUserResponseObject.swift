//
//  CovetUserResponseObject.swift
//  Covet
//
//  Created by Covet on 2/1/22.
//

import Foundation

struct CovetUserResponseObject : Decodable {
    var exists: Bool?
    var user: CovetUser?
}
